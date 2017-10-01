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

struct BoxSpaceIndexTests {
    static func testHash() throws {
        var schema = try Schema(Box())
        var space = try schema.createSpace(name: "test_hash")

        let hash = try space.createIndex(name: "hash", type: .hash)
        let expected = Index(id: 0, name: "hash", type: .hash, unique: true)
        try assertEqualThrows(hash, expected)
    }

    static func testTree() throws {
        var schema = try Schema(Box())
        var space = try schema.createSpace(name: "test_tree")

        let tree = try space.createIndex(name: "tree", type: .tree)
        let expected = Index(id: 0, name: "tree", type: .tree, unique: true)
        try assertEqualThrows(tree, expected)
    }

    static func testRTree() throws {
        var schema = try Schema(Box())
        var space = try schema.createSpace(name: "test_rtree")

        // primary key must be unique
        try space.createIndex(name: "primary", type: .hash)

        // RTREE index can not be unique
        let rtree = try space.createIndex(name: "rtree", type: .rtree)
        let expected = Index(id: 1, name: "rtree", type: .rtree)
        try assertEqualThrows(rtree, expected)
    }

    static func testBitset() throws {
        var schema = try Schema(Box())
        var space = try schema.createSpace(name: "test_bitset")

        // primary key must be unique
        try space.createIndex(name: "primary", type: .hash)

        // BITSET can not be unique
        let rtree = try space.createIndex(name: "bitset", type: .bitset)
        let expected = Index(id: 1, name: "bitset", type: .rtree)
        try assertEqualThrows(rtree, expected)
    }

    static func testSequence() throws {
        var schema = try Schema(Box())
        var space = try schema.createSpace(name: "test_sequence")

        let primary = try space.createIndex(
            name: "primary", type: .hash, sequence: true)
        let expected = Index(
            id: 0, name: "primary", type: .hash, sequenceId: 1, unique: true)
        try assertEqualThrows(primary, expected)
    }

    static func testMany() throws {
        var schema = try Schema(Box())
        var space = try schema.createSpace(name: "test_indexes")

        let hash = try space.createIndex(name: "hash", type: .hash)
        let expected0 = Index(id: 0, name: "hash", type: .hash, unique: true)
        try assertEqualThrows(hash, expected0)

        let tree = try space.createIndex(name: "tree", type: .tree)
        let expected1 = Index(id: 1, name: "tree", type: .tree, unique: true)
        try assertEqualThrows(tree, expected1)

        let rtree = try space.createIndex(name: "rtree", type: .rtree)
        let expected2 = Index(id: 2, name: "rtree", type: .rtree)
        try assertEqualThrows(rtree, expected2)

        let nonUnique = try space.createIndex(name: "non_unique", unique: false)
        let expected3 = Index(id: 3, name: "non_unique", type: .tree)
        try assertEqualThrows(nonUnique, expected3)
    }
}

// C API Wrappers

@_silgen_name("BoxSpaceIndexTests_testHash")
public func BoxSpaceIndexTests_testHash(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxSpaceIndexTests.testHash()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceIndexTests_testTree")
public func BoxSpaceIndexTests_testTree(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxSpaceIndexTests.testTree()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceIndexTests_testRTree")
public func BoxSpaceIndexTests_testRTree(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxSpaceIndexTests.testRTree()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceIndexTests_testBitset")
public func BoxSpaceIndexTests_testBitset(
    context: BoxContext
    ) -> BoxResult {
    do {
        try BoxSpaceIndexTests.testBitset()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceIndexTests_testSequence")
public func BoxSpaceIndexTests_testSequence(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxSpaceIndexTests.testSequence()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceIndexTests_testMany")
public func BoxSpaceIndexTests_testMany(
    context: BoxContext
) -> BoxResult {
    do {
        try BoxSpaceIndexTests.testMany()
        return 0
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}
