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
import MessagePack

public protocol IndexKey {
    var key: MessagePack { get }
}

extension Int: IndexKey {
    public var key: MessagePack {
        return .int(self)
    }
}

extension String: IndexKey {
    public var key: MessagePack {
        return .string(self)
    }
}

extension MessagePack: IndexKey {
    public var key: MessagePack {
        return self
    }
}

extension RawRepresentable where RawValue == IndexKey {
    var key: MessagePack {
        return rawValue.key
    }
}

extension Array where Element == IndexKey {
    public func encode() throws -> [UInt8] {
        let stream = OutputByteStream()
        var writer = MessagePackWriter(stream)
        try writer.encodeArrayItemsCount(count)
        for indexKey in self {
            try writer.encode(indexKey.key)
        }
        return stream.bytes
    }
}

extension Array where Element == IndexKey {
    public var rawValue: [MessagePack] {
        return self.map { $0.key }
    }
}
