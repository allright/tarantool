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
import TarantoolModule

struct BoxIndexTests {
    fileprivate static var space: Space<Box> {
        return try! Schema(Box()).spaces["test"]!
    }

    static func testHash() throws {
        let box = Box()
        var schema = try Schema(box)
        var space = try schema.createSpace(name: "test_hash")

        let hash = try space.createIndex(name: "hash", type: .hash)
        let expected = Index(
            spaceId: space.id,
            id: 0,
            name: "hash",
            type: .hash,
            unique: true,
            source: box)
        try assertEqualThrows(hash, expected)
    }

    static func testTree() throws {
        let box = Box()
        var schema = try Schema(box)
        var space = try schema.createSpace(name: "test_tree")

        let tree = try space.createIndex(name: "tree", type: .tree)
        let expected = Index(
            spaceId: space.id,
            id: 0,
            name: "tree",
            type: .tree,
            unique: true,
            source: box)
        try assertEqualThrows(tree, expected)
    }

    static func testRTree() throws {
        let box = Box()
        var schema = try Schema(box)
        var space = try schema.createSpace(name: "test_rtree")

        // primary key must be unique
        try space.createIndex(name: "primary", type: .hash)

        // RTREE index can not be unique
        let rtree = try space.createIndex(name: "rtree", type: .rtree)
        let expected = Index(
            spaceId: space.id,
            id: 1,
            name: "rtree",
            type: .rtree,
            source: box)
        try assertEqualThrows(rtree, expected)
    }

    static func testBitset() throws {
        let box = Box()
        var schema = try Schema(box)
        var space = try schema.createSpace(name: "test_bitset")

        // primary key must be unique
        try space.createIndex(name: "primary", type: .hash)

        // BITSET can not be unique
        let rtree = try space.createIndex(name: "bitset", type: .bitset)
        let expected = Index(
            spaceId: space.id,
            id: 1,
            name: "bitset",
            type: .bitset,
            source: box)
        try assertEqualThrows(rtree, expected)
    }

    static func testSequence() throws {
        let box = Box()
        var schema = try Schema(box)
        var space = try schema.createSpace(name: "test_sequence")

        let primary = try space.createIndex(
            name: "primary", type: .hash, sequence: true)
        let expected = Index(
            spaceId: space.id,
            id: 0, name: "primary",
            type: .hash,
            sequenceId: 1,
            unique: true,
            source: box)
        try assertEqualThrows(primary, expected)
    }

    static func testMany() throws {
        let box = Box()
        var schema = try Schema(box)
        var space = try schema.createSpace(name: "test_indices")

        let hash = try space.createIndex(name: "hash", type: .hash)
        let expected0 = Index(
            spaceId: space.id,
            id: 0,
            name: "hash",
            type: .hash,
            unique: true,
            source: box)
        try assertEqualThrows(hash, expected0)

        let tree = try space.createIndex(name: "tree", type: .tree)
        let expected1 = Index(
            spaceId: space.id,
            id: 1,
            name: "tree",
            type: .tree,
            unique: true,
            source: box)
        try assertEqualThrows(tree, expected1)

        let rtree = try space.createIndex(name: "rtree", type: .rtree)
        let expected2 = Index(
            spaceId: space.id,
            id: 2,
            name: "rtree",
            type: .rtree,
            source: box)
        try assertEqualThrows(rtree, expected2)

        let nonUnique = try space.createIndex(name: "non_unique", unique: false)
        let expected3 = Index(
            spaceId: space.id,
            id: 3,
            name: "non_unique",
            type: .tree,
            source: box)
        try assertEqualThrows(nonUnique, expected3)
    }

    static func testCount() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        let result = try index.count(iterator: .all)
        guard result == 3 else {
            throw "3 is not equal to \(result)"
        }
    }

    static func testSelect() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        let expected: [[MessagePack]] = [[1, "foo"], [2, "bar"], [3, "baz"]]
        let result = try index.select(iterator: .all)
        let converted = [[MessagePack]](result)
        guard converted == expected else {
            throw "\(converted) is not equal to \(expected)"
        }
    }

    static func testGet() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        let result = try index.get(keys: [3])
        guard let tuple = result, tuple.rawValue == [3, "baz"] else {
            throw "\(String(describing: result)) is not equal to [3, 'baz']"
        }
    }

    static func testInsert() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        try index.insert([4, "quux"])
        let result = try index.get(keys: [4])
        guard let tuple = result, tuple.rawValue == [4, "quux"] else {
            throw "\(String(describing: result))  is not equal to [4, 'quux']"
        }
    }

    static func testReplace() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        try index.replace([3, "zab"])
        let result = try index.get(keys: [3])
        guard let tuple = result, tuple.rawValue == [3, "zab"] else {
            throw "\(String(describing: result))  is not equal to [3, 'zab']"
        }
    }

    static func testDelete() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        try index.delete(keys: [3])
        let result = try index.get(keys: [3])
        guard result == nil else {
            throw "\(String(describing: result)) is not nil"
        }
    }

    static func testUpdate() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        try index.update(keys: [3], operations: [["=", 1, "zab"]])
        let result = try index.get(keys: [3])
        guard let tuple = result, tuple.rawValue == [3, "zab"] else {
            throw "\(String(describing: result)) is not equal to [3, 'zab']"
        }
    }

    static func testUpsert() throws {
        guard let index = space[index: "primary"] else {
            throw "index not found"
        }
        let expectedNil = try index.get(keys: [4])
        guard expectedNil == nil else {
            throw "\(String(describing: expectedNil)) is not nil"
        }

        try index.upsert([4, "quux", 42], operations: [["+", 2, 8]])
        let insert = try index.get(keys: [4])

        guard let insertResult = insert,
            insertResult.rawValue == [4, "quux", 42] else {
                throw String(describing: insert) +
                " is not equal to [4, 'quux', 42]"
        }

        try index.upsert([4, "quux", 42], operations: [["+", 2, 8]])
        let update = try index.get(keys: [4])

        guard let updateResult = update,
            updateResult.rawValue == [4, "quux", 50] else {
                throw String(describing: update) +
                    " is not equal to [4, 'quux', 50]"
        }
    }
}

// C API Wrappers

@_silgen_name("BoxIndexTests_testHash")
public func BoxIndexTests_testHash(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxIndexTests.testHash()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testTree")
public func BoxIndexTests_testTree(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxIndexTests.testTree()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testRTree")
public func BoxIndexTests_testRTree(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxIndexTests.testRTree()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testBitset")
public func BoxIndexTests_testBitset(
    context: BoxContext
    ) -> BoxResult {
    do {
        try BoxIndexTests.testBitset()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testSequence")
public func BoxIndexTests_testSequence(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxIndexTests.testSequence()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testMany")
public func BoxIndexTests_testMany(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxIndexTests.testMany()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testCount")
public func BoxIndexTests_testCount(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testCount()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testSelect")
public func BoxIndexTests_testSelect(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testSelect()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testGet")
public func BoxIndexTests_testGet(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testGet()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testInsert")
public func BoxIndexTests_testInsert(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testInsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testReplace")
public func BoxIndexTests_testReplace(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testReplace()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testDelete")
public func BoxIndexTests_testDelete(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testDelete()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testUpdate")
public func BoxIndexTests_testUpdate(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testUpdate()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxIndexTests_testUpsert")
public func BoxIndexTests_testUpsert(context: BoxContext) -> BoxResult {
    do {
        try BoxIndexTests.testUpsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}
