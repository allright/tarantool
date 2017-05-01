/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

fileprivate let headerSize = 64
fileprivate let saltSize = 44
fileprivate let size = 128

struct Welcome {
    var header: String
    var salt: String

    static var packetSize: Int {
        return size
    }

    init(from bytes: [UInt8]) throws {
        self.header = String(slice: bytes.prefix(upTo: headerSize))
        self.salt = String(slice: bytes[headerSize..<headerSize+saltSize])

        guard header.hasPrefix("Tarantool") else {
            throw IProtoError.invalidWelcome(reason: .invalidHeader)
        }
    }
}

fileprivate extension String {
    init(slice: ArraySlice<UInt8>) {
        self = String(cString: Array(slice) + [0])
    }
}
