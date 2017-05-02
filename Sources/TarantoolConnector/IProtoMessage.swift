/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

struct IProtoMessage {
    let code: Code
    let sync: Int?
    let schemaId: Int?

    let body: Keys
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

extension IProtoMessage {
    func encode(to bytes: inout [UInt8]) throws {
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

        var encoder = Encoder()
        encoder.encode(header)
        encoder.encode(body)

        // body + header size
        let size = try HeaderLength(encoder.bytes.count).bytes
        bytes.append(contentsOf: size)
        bytes.append(contentsOf: encoder.bytes)
    }
}

extension IProtoMessage {
    init(from bytes: [UInt8]) throws {
        var decoder = Decoder(bytes: bytes, count: bytes.count)

        guard let header =
            try? decoder.decode([MessagePack : MessagePack].self),
            header.count == 3,
            let packedCode = header[Key.code.rawValue],
            let unpackedCode = Int(packedCode),
            let sync = header[Key.sync.rawValue],
            let schemaId = header[Key.schemaId.rawValue] else {
                throw IProtoError.invalidPacket(reason: .invalidHeader)
        }

        guard let body =
            try? decoder.decode([MessagePack : MessagePack].self) else {
                throw IProtoError.invalidPacket(reason: .invalidBodyHeader)
        }

        guard unpackedCode < 0x8000 else {
            // error packed as [0x31 : MP_STRING]
            let message = String(body[Key.error.rawValue]) ?? "unknown"
            throw IProtoError.badRequest(code: unpackedCode, message: message)
        }

        guard let code = Code(rawValue: packedCode) else {
            throw IProtoError.invalidPacket(reason: .invalidCode)
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
            throw IProtoError.invalidPacket(reason: .invalidBody)
        }
        self.body = [Key.data: object]
    }
}
