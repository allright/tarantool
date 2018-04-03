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

private let headerSize = 64
private let saltSize = 44
private let size = 128

extension IProto {
    struct Welcome {
        var header: String
        var salt: String

        static var packetSize: Int {
            return size
        }

        init<T: StreamReader>(from stream: inout T) throws {
            var buffer = try stream.read(count: Welcome.packetSize)
            self.header = String(slice: buffer.prefix(upTo: headerSize))
            self.salt = String(slice: buffer[headerSize..<headerSize+saltSize])

            guard header.hasPrefix("Tarantool") else {
                throw IProto.Error.invalidWelcome(reason: .invalidHeader)
            }
        }
    }
}

private extension String {
    init(slice: ArraySlice<UInt8>) {
        self = String(cString: Array(slice) + [0])
    }
}
