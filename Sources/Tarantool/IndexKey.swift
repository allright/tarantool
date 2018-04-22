/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

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
