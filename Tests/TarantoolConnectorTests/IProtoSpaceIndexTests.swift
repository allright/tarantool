/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Test
import AsyncDispatch
@testable import TestUtils
@testable import TarantoolConnector

class IProtoSpaceIndexTests: TestCase {
    var tarantool: TarantoolProcess!
    var connection: IProtoConnection!

    override func setUp() {
        do {
            AsyncDispatch().registerGlobal()
            tarantool = try TarantoolProcess(with: """
                box.schema.user.grant('guest', 'read,write,execute', 'universe')
                box.schema.user.passwd('admin', 'admin')
                """)
            try tarantool.launch()

            connection = try IProtoConnection(
                host: "127.0.0.1",
                port: tarantool.port)
        } catch {
            fail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testHash() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))
            var space = try schema.createSpace(name: "test_hash")

            let hash = try space.createIndex(name: "hash", type: .hash)
            let expected = Index(id: 0, name: "hash", type: .hash, unique: true)
            assertEqual(hash, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testTree() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))
            var space = try schema.createSpace(name: "test_tree")

            let tree = try space.createIndex(name: "tree", type: .tree)
            let expected = Index(id: 0, name: "tree", type: .tree, unique: true)
            assertEqual(tree, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testRTree() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))
            var space = try schema.createSpace(name: "test_rtree")

            // primary key must be unique
            try space.createIndex(name: "primary", type: .hash)

            // RTREE index can not be unique
            let rtree = try space.createIndex(name: "rtree", type: .rtree)
            let expected = Index(id: 1, name: "rtree", type: .rtree)
            assertEqual(rtree, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testBitset() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))
            var space = try schema.createSpace(name: "test_bitset")

            // primary key must be unique
            try space.createIndex(name: "primary", type: .hash)

            // BITSET can not be unique
            let rtree = try space.createIndex(name: "bitset", type: .bitset)
            let expected = Index(id: 1, name: "bitset", type: .bitset)
            assertEqual(rtree, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSequence() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))
            var space = try schema.createSpace(name: "test_sequence")

            let primary = try space.createIndex(
                name: "primary", type: .hash, sequence: true)
            let expected = Index(
                id: 0, name: "primary", type: .hash,
                sequenceId: 1, unique: true)
            assertEqual(primary, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testMany() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))

            var space = try schema.createSpace(name: "test_indexes")

            let hash = try space.createIndex(name: "i0", type: .hash)
            let expected0 = Index(id: 0, name: "i0", type: .hash, unique: true)
            assertEqual(hash, expected0)

            let tree = try space.createIndex(name: "i1")
            let expected1 = Index(id: 1, name: "i1", type: .tree, unique: true)
            assertEqual(tree, expected1)

            let rtree = try space.createIndex(name: "i2", type: .rtree)
            let expected2 = Index(id: 2, name: "i2", type: .rtree)
            assertEqual(rtree, expected2)

            let nonUnique = try space.createIndex(name: "i3", unique: false)
            let expected3 = Index(id: 3, name: "i3", type: .tree)
            assertEqual(nonUnique, expected3)
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testHash", testHash),
        ("testTree", testTree),
        ("testRTree", testRTree),
        ("testBitset", testBitset),
        ("testSequence", testSequence),
        ("testMany", testMany),
    ]
}
