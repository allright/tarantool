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

public struct Space<T: DataSource> {
    public let id: Int
    private let source: T

    public init(id: Int, source: T) {
        self.id = id
        self.source = source
    }

    public func count(
        _ iterator: Iterator = .all, keys: [MessagePack] = [], indexId: Int = 0
    ) throws -> Int {
        return try source.count(id, indexId, iterator, keys)
    }

    public func select(
        _ iterator: Iterator,
        keys: [MessagePack] = [],
        indexId: Int = 0,
        offset: Int = 0,
        limit: Int = Int.max
    ) throws -> AnySequence<T.Row> {
        return try source.select(id, indexId, iterator, keys, offset, limit)
    }

    public func get(_ keys: [MessagePack], indexId: Int = 0) throws -> T.Row? {
        return try source.get(id, indexId, keys)
    }

    public func insert(_ tuple: [MessagePack]) throws {
        try source.insert(id, tuple)
    }

    public func insert(autoincrementing tuple: [MessagePack]) throws -> Int {
        return try source.insertAutoincrement(id, tuple)
    }

    public func replace(_ tuple: [MessagePack]) throws {
        try source.replace(id, tuple)
    }

    public func delete(_ keys: [MessagePack], indexId: Int = 0) throws {
        try source.delete(id, indexId, keys)
    }

    public func update(
        _ keys: [MessagePack], operations: [MessagePack], indexId: Int = 0
    ) throws {
        try source.update(id, indexId, keys, operations)
    }

    public func upsert(
        _ tuple: [MessagePack], operations: [MessagePack], indexId: Int = 0
    ) throws {
        try source.upsert(id, indexId, tuple, operations)
    }
}

extension Space: CustomStringConvertible {
    public var description: String {
        return "space: \(id)"
    }
}
