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
    public struct Part {
        let field: Int
        let type: Type

        public init(field: Int, type: Type) {
            self.field = field
            self.type = type
        }

        public enum `Type`: String {
            case unsigned
            case integer
            case string
            case array
        }
    }
}

public struct Index<T: DataSource> {
    public let spaceId: Int
    public let id: Int
    public let name: String
    public let type: Type
    public let sequenceId: Int?
    public let isUnique: Bool
    public let parts: [Part]

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
        parts: [Part],
        source: T
    ) {
        self.spaceId = spaceId
        self.id = id
        self.name = name
        self.type = type
        self.sequenceId = sequenceId
        self.isUnique = unique
        self.source = source
        self.parts = parts
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
            lhs.isUnique == rhs.isUnique &&
            lhs.parts == rhs.parts
    }
}

extension Index.Part: Equatable {
    public static func ==(lhs: Index<T>.Part, rhs: Index<T>.Part) -> Bool {
        return lhs.field == rhs.field && lhs.type == rhs.type
    }
}

// Decoding from MessagePack

extension Index {
    // FIXME
    typealias IndexType = Index.`Type`

    init?<M: Tarantool.Tuple>(from messagePack: M, source: T) {
        guard messagePack.count >= 6,
            let spaceId = Int(messagePack[0]),
            let id = Int(messagePack[1]),
            let name = String(messagePack[2]),
            let typeString = String(messagePack[3]),
            let type = IndexType(rawValue: typeString),
            let options = [MessagePack : MessagePack](messagePack[4]),
            let partsArray = [MessagePack](messagePack[5]),
            let parts = Index.Part.parseMany(from: partsArray),
            let unique = Bool(options["unique"]) else {
                return nil
        }
        self = Index(
            spaceId: spaceId,
            id: id,
            name: name,
            type: type,
            unique: unique,
            parts: parts,
            source: source)
    }
}

extension Index.Part {
    // TODO: extension Array where Element == Index.Part
    static func parseMany(from array: [MessagePack]) -> [Index.Part]? {
        var parts = [Index.Part]()
        for item in array {
            switch item {
            case .map(let map):
                if let value = Index.Part(map) {
                    parts.append(value)
                }
            case .array(let array):
                if let value = Index.Part(array) {
                    parts.append(value)
                }
            default:
                continue
            }
        }
        guard parts.count == array.count else {
            return nil
        }
        return parts
    }

    init?(_ array: [MessagePack]) {
        guard array.count >= 2,
            let field = Int(array[0]),
            let rawType = String(array[1]),
            let type = Type(rawValue: rawType) else {
                return nil
        }
        self.field = field
        self.type = type
    }

    init?(_ map: [MessagePack : MessagePack]) {
        guard map.count >= 2,
            let rawType = String(map["type"]),
            let type = Type(rawValue: rawType) else {
                return nil
        }

        if let field = Int(map["field"]) {
            self.field = field
        } else if let field = Int(map["fieldno"]) {
            self.field = field
        } else {
            return nil
        }

        self.type = type
    }
}
