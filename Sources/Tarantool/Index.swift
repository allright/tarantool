/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import MessagePack

extension Index {
    public enum `Type`: String {
        case hash
        case tree
        case bitset
        case rtree
    }
}

extension Index {
    public enum PartType: String {
        case unsigned
        case integer
        case string
        case array
    }
}

public struct Index<T: DataSource> {
    public let spaceId: Int
    public let id: Int
    public let name: String
    public let type: Type
    public let sequenceId: Int?
    public let isUnique: Bool

    private let source: T

    public var isSequence: Bool {
        return sequenceId != nil
    }

    public init(
        spaceId: Int,
        id: Int,
        name: String,
        type: Type,
        sequenceId: Int? = nil,
        unique: Bool = false,
        source: T
    ) {
        self.spaceId = spaceId
        self.id = id
        self.name = name
        self.type = type
        self.sequenceId = sequenceId
        self.isUnique = unique
        self.source = source
    }
}

extension Index {
    public func count(
        iterator: Iterator,
        keys: [MessagePack] = []
    ) throws -> Int {
        return try source.count(spaceId, id, iterator, keys)
    }

    public func select(
        iterator: Iterator,
        keys: [MessagePack] = [],
        offset: Int = 0,
        limit: Int = Int.max
    ) throws -> AnySequence<T.Row> {
        return try source.select(spaceId, id, iterator, keys, offset, limit)
    }

    public func get(keys: [MessagePack]) throws -> T.Row? {
        return try source.get(spaceId, id, keys)
    }

    public func insert(_ tuple: [MessagePack]) throws {
        return try source.insert(spaceId, tuple)
    }

    public func replace(_ tuple: [MessagePack]) throws {
        return try source.replace(spaceId, tuple)
    }

    public func delete(keys: [MessagePack]) throws {
        try source.delete(spaceId, id, keys)
    }

    public func update(keys: [MessagePack], operations: [MessagePack]) throws {
        try source.update(spaceId, id, keys, operations)
    }

    public func upsert(
        _ tuple: [MessagePack],
        operations: [MessagePack]
    ) throws {
        try source.upsert(spaceId, id, tuple, operations)
    }
}

extension Index: Equatable {
    public static func ==(lhs: Index, rhs: Index) -> Bool {
        return lhs.spaceId == rhs.spaceId &&
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.sequenceId == rhs.sequenceId &&
            lhs.isUnique == rhs.isUnique
    }
}
