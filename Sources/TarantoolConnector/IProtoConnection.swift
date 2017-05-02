/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Network
import Foundation

@_exported import Tarantool
@_exported import MessagePack

public typealias Keys = [Key : MessagePack]

public class IProtoConnection {
    let socket: Socket
    let welcome: Welcome

    public init(
        host: String, port: UInt16 = 3301, awaiter: IOAwaiter? = nil
    ) throws {
        socket = try Socket(awaiter: awaiter)
        try socket.connect(to: host, port: port)

        var buffer = [UInt8](repeating: 0, count: Welcome.packetSize)
        guard try socket.receive(to: &buffer) == Welcome.packetSize else {
            throw IProtoError.invalidWelcome(reason: .invalidSize)
        }
        welcome = try Welcome(from: buffer)
    }

    deinit {
        try? socket.close(silent: true)
    }

    public func request(
        code: Code,
        keys: Keys = [:],
        sync: Int? = nil,
        schemaId: Int? = nil
    ) throws -> [MessagePack] {
        let request = IProtoMessage(
            code: code,
            sync: sync,
            schemaId: schemaId,
            body: keys
        )
        var requestBytes = [UInt8]()
        try request.encode(to: &requestBytes)
        _ = try socket.send(bytes: requestBytes)

        let length = try readPacketLength()
        var buffer = [UInt8](repeating: 0, count: length)
        guard try socket.receive(to: &buffer) == length else {
            throw IProtoError.invalidPacket(reason: .invalidSize)
        }

        let response = try IProtoMessage(from: buffer)

        return Array(response.body[Key.data]) ?? []
    }

    private func readPacketLength() throws -> Int {
        // always packed as 32bit integer CE XX XX XX XX
        var buffer = [UInt8](repeating: 0, count: 5)
        guard try socket.receive(to: &buffer) == 5 else {
            throw IProtoError.invalidPacket(reason: .invalidSize)
        }
        return try HeaderLength(bytes: buffer).value
    }
}

extension IProtoConnection {
    public func ping() throws {
        _ = try request(code: .ping)
    }

    public func call(
        _ function: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try request(
            code: .call,
            keys: [.functionName: .string(function), .tuple: .array(arguments)]
        )
    }

    public func eval(
        _ expression: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try request(
            code: .eval,
            keys: [.expression: .string(expression), .tuple: .array(arguments)]
        )
    }

    public func auth(username: String, password: String) throws {
        let data = [UInt8](password.utf8)
        guard let salt = Data(base64Encoded: welcome.salt) else {
            throw IProtoError.invalidSalt
        }

        let scramble = data.chapSha1(salt: [UInt8](salt))

        let keys: Keys = [
            .username: .string(username),
            .tuple: .array([.string("chap-sha1"), .binary(scramble)])
        ]
        _ = try request(code: .auth, keys: keys)
    }
}
