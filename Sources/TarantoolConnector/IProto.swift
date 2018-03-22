/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Stream
import Network
import Foundation

@_exported import Tarantool
@_exported import MessagePack

public class IProto {
    let socket: Socket
    var stream: BufferedStream<NetworkStream>
    let welcome: Welcome

    public init(host: String, port: Int = 3301) throws {
        socket = try Socket().connect(to: host, port: port)
        stream = BufferedStream(baseStream: NetworkStream(socket: socket))
        welcome = try Welcome(from: &stream)
    }

    deinit {
        try? socket.close()
    }

    public typealias Code = Message.Code
    public typealias Key = Message.Key

    public func request(
        code: Code,
        keys: [Key : MessagePack] = [:],
        sync: Int? = nil,
        schemaId: Int? = nil
    ) throws -> [MessagePack] {
        let request = Message(
            code: code,
            sync: sync,
            schemaId: schemaId,
            body: keys
        )

        try request.encode(to: &stream)
        try stream.flush()

        let response = try Message(from: stream)

        return response.body[Message.Key.data]?.arrayValue ?? []
    }
}

extension IProto {
    public func ping() throws {
        _ = try request(code: .ping)
    }

    public func auth(username: String, password: String) throws {
        let data = [UInt8](password.utf8)
        guard let salt = Data(base64Encoded: welcome.salt) else {
            throw IProto.Error.invalidSalt
        }

        let scramble = data.chapSha1(salt: [UInt8](salt))

        let keys: [Key : MessagePack] = [
            .username: .string(username),
            .tuple: .array([
                .string("chap-sha1"),
                .binary(scramble)
            ])
        ]
        _ = try request(code: .auth, keys: keys)
    }
}
