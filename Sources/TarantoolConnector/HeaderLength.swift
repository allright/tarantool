/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

struct HeaderLength {
    static func pack(_ value: Int) throws -> [UInt8] {
        guard value <= Int(Int32.max) else {
            throw IProtoError.invalidPacket(reason: .invalidSize)
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
