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
            case number
            case string
            case boolean
            case array
            case scalar
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
        keys: [IndexKey] = []
    ) throws -> Int {
        return try source.count(spaceId, id, iterator, keys)
    }

    public func select(
        iterator: Iterator,
        keys: [IndexKey] = [],
        offset: Int = 0,
        limit: Int = Int.max
    ) throws -> AnySequence<T.Row> {
        return try source.select(spaceId, id, iterator, keys, offset, limit)
    }

    public func get(keys: [IndexKey]) throws -> T.Row? {
        return try source.get(spaceId, id, keys)
    }

    @discardableResult
    public func insert(_ tuple: [MessagePack]) throws -> MessagePack {
        return try source.insert(spaceId, tuple)
    }

    public func replace(_ tuple: [MessagePack]) throws {
        return try source.replace(spaceId, tuple)
    }

    public func delete(keys: [IndexKey]) throws {
        try source.delete(spaceId, id, keys)
    }

    public func update(keys: [IndexKey], operations: [MessagePack]) throws {
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
            let spaceId = messagePack[0]?.integerValue,
            let id = messagePack[1]?.integerValue,
            let name = messagePack[2]?.stringValue,
            let typeString = messagePack[3]?.stringValue,
            let type = IndexType(rawValue: typeString.lowercased()),
            let options = messagePack[4]?.dictionaryValue,
            let partsArray = messagePack[5]?.arrayValue,
            let parts = [Index<T>.Part](from: partsArray),
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

protocol IndexPartProtocol {
    init?(_ array: [MessagePack])
    init?(_ map: [MessagePack : MessagePack])
}
// extension Array where Element == Index<T>.Part
extension Index.Part: IndexPartProtocol {}

extension Array where Element: IndexPartProtocol {
    init?(from array: [MessagePack]) {
        var parts = [Element]()
        for item in array {
            switch item {
            case .map(let map):
                if let value = Element(map) {
                    parts.append(value)
                }
            case .array(let array):
                if let value = Element(array) {
                    parts.append(value)
                }
            default:
                continue
            }
        }
        guard parts.count == array.count else {
            return nil
        }
        self = parts
    }
}

extension Index.Part {
     init?(_ array: [MessagePack]) {
        guard array.count >= 2,
            let field = array[0].integerValue,
            let rawType = array[1].stringValue,
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
