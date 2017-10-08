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

extension IProto {
    struct Message {
        let code: Code
        let sync: Int?
        let schemaId: Int?

        let body: [Key : MessagePack]
    }
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

extension IProto.Message {
    func encode<T: OutputStream>(to stream: inout T) throws {
        // header
        var header: Map = [:]
        header[Key.code.rawValue] = code.rawValue
        if let sync = sync {
            header[Key.sync.rawValue] = .int(sync)
        }
        if let schemaId = schemaId {
            header[Key.schemaId.rawValue] = .int(schemaId)
        }

        //body
        var body: Map = [:]
        for (key, value) in self.body {
            body[key.rawValue] = value
        }

        var encoder = MessagePackWriter(OutputByteStream())
        try encoder.encode(header)
        try encoder.encode(body)

        // body + header size
        let packet = encoder.stream.bytes
        let size = try Length.pack(packet.count)
        guard try stream.write(size) == size.count,
            try stream.write(packet) == packet.count else {
                throw IProto.Error.streamWriteFailed
        }
    }
}

extension IProto.Message {
    init<T: InputStream>(from stream: T) throws {
        var decoder = MessagePackReader(stream)
        let size = try decoder.decode(Int.self)
        // we don't actually need the size because of stream
        guard size > 0 else {
            throw IProto.Error.invalidPacket(reason: .invalidSize)
        }

        guard let header =
            try? decoder.decode([MessagePack : MessagePack].self),
            header.count == 3,
            let packedCode = header[Key.code.rawValue],
            let unpackedCode = Int(packedCode),
            let sync = header[Key.sync.rawValue],
            let schemaId = header[Key.schemaId.rawValue] else {
                throw IProto.Error.invalidPacket(reason: .invalidHeader)
        }

        guard let body =
            try? decoder.decode([MessagePack : MessagePack].self) else {
                throw IProto.Error.invalidPacket(reason: .invalidBodyHeader)
        }

        guard unpackedCode < 0x8000 else {
            // error packed as [0x31 : MP_STRING]
            let message = String(body[Key.error.rawValue]) ?? "unknown"
            throw IProto.Error.badRequest(code: unpackedCode, message: message)
        }

        guard let code = Code(rawValue: packedCode) else {
            throw IProto.Error.invalidPacket(reason: .invalidCode)
        }

        self.code = code
        self.sync = Int(sync)
        self.schemaId = Int(schemaId)

        // empty body e.g. ping response
        guard body.count > 0 else {
            self.body = [:]
            return
        }

        // response packed as [0x30 : MP_OBJECT]
        guard let object = body[Key.data.rawValue] else {
            throw IProto.Error.invalidPacket(reason: .invalidBody)
        }
        self.body = [Key.data: object]
    }
}

extension IProto.Message {
    struct Length {
        static func pack(_ value: Int) throws -> [UInt8] {
            guard value <= Int(Int32.max) else {
                throw IProto.Error.invalidPacket(reason: .invalidSize)
            }
            var bytes = [UInt8](repeating: 0, count: 5)
            bytes[0] = 0xce
            bytes[1] = UInt8(truncatingIfNeeded: value >> 24)
            bytes[2] = UInt8(truncatingIfNeeded: value >> 16)
            bytes[3] = UInt8(truncatingIfNeeded: value >> 8)
            bytes[4] = UInt8(truncatingIfNeeded: value)
            return bytes
        }

        static func unpack(bytes: [UInt8]) throws -> Int {
            guard bytes[0] == 0xce else {
                throw MessagePackError.invalidData
            }
            guard bytes.count >= 5 else {
                throw MessagePackError.insufficientData
            }

            // FIXME: expression was too complex
            let byte1 = Int(bytes[1]) << 24
            let byte2 = Int(bytes[2]) << 16
            let byte3 = Int(bytes[3]) << 8
            let byte4 = Int(bytes[4])

            return byte1 | byte2 | byte3 | byte4
        }
    }
}
