import Stream

extension IProto {
    public struct Message {
        let code: Code
        let sync: Int?
        let schemaId: Int?

        let body: [Key : MessagePack]
    }
}

extension IProto.Message {
    public enum Code: MessagePack {
        case response  = 0x00

        case select    = 0x01
        case insert    = 0x02
        case replace   = 0x03
        case update    = 0x04
        case delete    = 0x05
        case auth      = 0x07
        case eval      = 0x08
        case upsert    = 0x09
        case call      = 0x0A

        case ping      = 0x40
        case join      = 0x41
        case subscribe = 0x42
    }

    public enum Key: MessagePack {
        case code         = 0x00
        case sync         = 0x01
        /* Replication keys (header) */
        case serverId     = 0x02
        case lsn          = 0x03
        case timestamp    = 0x04
        case schemaId     = 0x05
        /* Leave a gap for other keys in the header. */
        case spaceId      = 0x10
        case indexId      = 0x11
        case limit        = 0x12
        case offset       = 0x13
        case iterator     = 0x14
        case indexBase    = 0x15
        /* Leave a gap between integer values and other keys */
        case key          = 0x20
        case tuple        = 0x21
        case functionName = 0x22
        case username     = 0x23
        /* Replication keys (body) */
        case serverUUID   = 0x24
        case clusterUUID  = 0x25
        case vClock       = 0x26
        case expression   = 0x27 /* eval */
        case ops          = 0x28 /* UPSERT but not UPDATE ops, because of legacy */
        /* Leave a gap between request keys and response keys */
        case data         = 0x30
        case error        = 0x31
        case keyMax
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
    func encode<T: StreamWriter>(to stream: T) throws {
        // header
        var header = [MessagePack : MessagePack]()
        header[Key.code.rawValue] = code.rawValue
        if let sync = sync {
            header[Key.sync.rawValue] = .int(sync)
        }
        if let schemaId = schemaId {
            header[Key.schemaId.rawValue] = .int(schemaId)
        }

        //body
        var body = [MessagePack : MessagePack]()
        for (key, value) in self.body {
            body[key.rawValue] = value
        }

        let byteStream = OutputByteStream()
        var encoder = MessagePackWriter(byteStream)
        try encoder.encode(header)
        try encoder.encode(body)

        // body + header size
        let packet = byteStream.bytes
        let size = try Length.pack(packet.count)
        try stream.write(size)
        try stream.write(packet)
    }
}

extension IProto.Message {
    init<T: StreamReader>(from stream: T) throws {
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
            let unpackedCode = packedCode.integerValue,
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
        self.sync = sync.integerValue
        self.schemaId = schemaId.integerValue

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
    }
}
