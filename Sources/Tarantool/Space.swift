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

import Foundation
import MessagePack

extension Space {
    public enum Engine: String {
        case sysview
        case memtx
        case vinyl
    }
}

public final class Space<T: DataSource & LuaScript> {
    public let id: Int
    public let name: String
    public let engine: Engine
    public var indices: [Index<T>]

    let source: T

    private let primaryIndex = 0

    public init(
        id: Int,
        name: String,
        engine: Engine,
        indices: [Index<T>],
        source: T
    ) {
        self.id = id
        self.name = name
        self.engine = engine
        self.indices = indices
        self.source = source
    }

    public subscript(index id: Int) -> Index<T>? {
        get {
            return indices[id]
        }
    }

    public subscript(index name: String) -> Index<T>? {
        get {
            return indices.first(where: { $0.name == name })
        }
    }

    public func count(
        _ iterator: Iterator = .all, keys: [IndexKey] = []
    ) throws -> Int {
        return try source.count(id, primaryIndex, iterator, keys)
    }

    public func select(
        iterator: Iterator,
        keys: [IndexKey] = [],
        offset: Int = 0,
        limit: Int = Int.max
    ) throws -> AnySequence<T.Row> {
        return try source.select(
            id, primaryIndex, iterator, keys, offset, limit)
    }

    public func get(keys: [IndexKey]) throws -> T.Row? {
        return try source.get(id, primaryIndex, keys)
    }

    @discardableResult
    public func insert(_ tuple: [MessagePack]) throws -> MessagePack {
        return try source.insert(id, tuple)
    }

    public func replace(_ tuple: [MessagePack]) throws {
        try source.replace(id, tuple)
    }

    public func delete(keys: [IndexKey]) throws {
        try source.delete(id, primaryIndex, keys)
    }

    public func update(
        keys: [IndexKey], operations: [MessagePack]
    ) throws {
        try source.update(id, primaryIndex, keys, operations)
    }

    public func upsert(
        _ tuple: [MessagePack], operations: [MessagePack]
    ) throws {
        try source.upsert(id, primaryIndex, tuple, operations)
    }
}

extension Space: CustomStringConvertible {
    public var description: String {
        return "space id: \(id), name: \(name)"
    }
}
