/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Foundation
import MessagePack

public struct Space<T: DataSource & LuaScript> {
    public let id: Int
    public let name: String
    public var indices: [Index<T>]

    let source: T

    private let primaryIndex = 0

    public init(id: Int, name: String, indices: [Index<T>], source: T) {
        self.id = id
        self.name = name
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

    public func insert(_ tuple: [MessagePack]) throws {
        try source.insert(id, tuple)
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
