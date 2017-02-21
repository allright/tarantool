/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Socket
import Foundation

@_exported import Tarantool
@_exported import MessagePack

public typealias Keys = [Key : MessagePack]

public class IProtoConnection {
    let socket: Socket
    let welcome: Welcome

    public init(host: String, port: UInt16 = 3301, awaiter: IOAwaiter? = nil) throws {
        socket = try Socket(awaiter: awaiter)
        try socket.connect(to: host, port: port)

        welcome = Welcome()
        guard try socket.receive(to: &welcome.buffer) == welcome.buffer.count else {
            throw IProtoError.invalidWelcome(reason: .invalidSize)
        }

        guard welcome.isValid else {
            throw IProtoError.invalidWelcome(reason: .invalidHeader)
        }
    }

    deinit {
        try? socket.close(silent: true)
    }

    //  Request/Response:
    //
    //  0        5
    //  +--------+ +============+ +===================================+
    //  | BODY + | |            | |                                   |
    //  | HEADER | |   HEADER   | |               BODY                |
    //  |  SIZE  | |            | |                                   |
    //  +--------+ +============+ +===================================+
    //    MP_INT       MP_MAP                     MP_MAP

    //  UNIFIED HEADER:
    //
    //  +================+================+=====================+
    //  |                |                |                     |
    //  |   0x00: CODE   |   0x01: SYNC   |    0x05: SCHEMA_ID  |
    //  | MP_INT: MP_INT | MP_INT: MP_INT |  MP_INT: MP_INT     |
    //  |                |                |                     |
    //  +================+================+=====================+
    //                            MP_MAP

    private func send(code: Code, keys: Keys = [:], sync: MessagePack? = nil, schemaId: MessagePack? = nil) throws {
        // header
        var header: Map = [:]
        header[Key.code.rawValue] = code.rawValue
        if let sync = sync {
            header[Key.sync.rawValue] = sync
        }
        if let schemaId = schemaId {
            header[Key.schemaId.rawValue] = schemaId
        }

        // body
        var body: Map = [:]
        for (key, value) in keys {
            body[key.rawValue] = value
        }

        var encoder = Encoder()
        encoder.encode(header)
        encoder.encode(body)
        let packet = encoder.bytes

        // body + header size
        let size = try HeaderLength(packet.count).bytes

        _ = try socket.send(bytes: size + packet)
    }

    private func receive() throws -> (header: MessagePack, body: MessagePack) {
        let length = try readPacketLength()

        var buffer = [UInt8](repeating: 0, count: length)
        guard try socket.receive(to: &buffer) == length else {
            throw IProtoError.invalidPacket(reason: .invalidSize)
        }

        var decoder = Decoder(bytes: buffer)
        let header = try decoder.decode() as MessagePack
        let body = try decoder.decode() as MessagePack

        return (header, body)
    }

    private func readPacketLength() throws -> Int {
        // always packed as 32bit integer CE XX XX XX XX
        var lengthBuffer = [UInt8](repeating: 0, count: 5)
        guard try socket.receive(to: &lengthBuffer) == 5 else {
            throw IProtoError.invalidPacket(reason: .invalidSize)
        }
        return try HeaderLength(bytes: lengthBuffer).length
    }

    public func request(code: Code, keys: Keys = [:], sync: MessagePack? = nil, schemaId: MessagePack? = nil) throws -> Tuple {
        try send(code: code, keys: keys, sync: sync, schemaId: schemaId)
        let (encodedHeader, encodedBody) = try receive()

        guard let header = Map(encodedHeader), header.count == 3,
            let code = Int(header[0]) else {
                throw IProtoError.invalidPacket(reason: .invalidHeader)
        }

        guard let body = Map(encodedBody) else {
            throw IProtoError.invalidPacket(reason: .invalidBodyHeader)
        }

        guard code < 0x8000 else {
            // error packed as [0x31 : MP_STRING]
            let message = String(body[Key.error.rawValue]) ?? "unknown"
            throw IProtoError.badRequest(code: code, message: message)
        }

        // empty body e.g. ping response
        guard body.count > 0 else {
            return []
        }

        // response packed as [0x30 : MP_OBJECT]
        guard let response = Tuple(body[Key.data.rawValue]) else {
            throw IProtoError.invalidPacket(reason: .invalidBody)
        }

        return response
    }
}

extension IProtoConnection {
    public func ping() throws {
        _ = try request(code: .ping)
    }

    public func call(_ function: String, arguments: Tuple = []) throws -> Tuple {
        return try request(
            code: .call,
            keys: [.functionName: .string(function), .tuple: .array(arguments)]
        )
    }

    public func eval(_ expression: String, arguments: Tuple = []) throws -> Tuple {
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
