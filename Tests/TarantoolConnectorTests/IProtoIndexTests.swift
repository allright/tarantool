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

class IProtoIndexTests: TestCase {
    var tarantool: TarantoolProcess!
    var connection: IProtoConnection!
    var space: Space<IProto>!

    override func setUp() {
        do {
            AsyncDispatch().registerGlobal()
            tarantool = try TarantoolProcess(with: """
                box.schema.user.grant('guest', 'read,write,execute', 'universe')
                box.schema.user.passwd('admin', 'admin')
                local test = box.schema.space.create('test')
                test:create_index('primary', {type = 'tree', parts = {1, 'unsigned'}})
                test:replace({1, 'foo'})
                test:replace({2, 'bar'})
                test:replace({3, 'baz'})
                """)
            try tarantool.launch()

            connection = try IProtoConnection(
                host: "127.0.0.1",
                port: tarantool.port)

            let iproto = IProto(connection: connection)
            let schema = try Schema(iproto)
            self.space = schema.spaces["test"]
        } catch {
            fatalError(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testHash() {
        do {
            try connection.auth(username: "admin", password: "admin")
            let iproto = IProto(connection: connection)
            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "test_hash")

            let hash = try space.createIndex(name: "hash", type: .hash)
            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "hash",
                type: .hash,
                unique: true,
                source: iproto)
            assertEqual(hash, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testTree() {
        do {
            try connection.auth(username: "admin", password: "admin")
            let iproto = IProto(connection: connection)
            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "test_tree")

            let tree = try space.createIndex(name: "tree", type: .tree)
            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "tree",
                type: .tree,
                unique: true,
                source: iproto)
            assertEqual(tree, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testRTree() {
        do {
            try connection.auth(username: "admin", password: "admin")
            let iproto = IProto(connection: connection)
            var schema = try Schema(iproto)
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
                source: iproto)
            assertEqual(rtree, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testBitset() {
        do {
            try connection.auth(username: "admin", password: "admin")
            let iproto = IProto(connection: connection)
            var schema = try Schema(iproto)
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
                source: iproto)
            assertEqual(rtree, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSequence() {
        do {
            try connection.auth(username: "admin", password: "admin")
            let iproto = IProto(connection: connection)
            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "test_sequence")

            let primary = try space.createIndex(
                name: "primary", type: .hash, sequence: true)
            let expected = Index(
                spaceId: space.id,
                id: 0, name: "primary",
                type: .hash,
                sequenceId: 1,
                unique: true,
                source: iproto)
            assertEqual(primary, expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testMany() {
        do {
            try connection.auth(username: "admin", password: "admin")
            let iproto = IProto(connection: connection)
            var schema = try Schema(iproto)

            var space = try schema.createSpace(name: "test_indexes")

            let hash = try space.createIndex(name: "hash", type: .hash)
            let expected0 = Index(
                spaceId: space.id,
                id: 0,
                name: "hash",
                type: .hash,
                unique: true,
                source: iproto)
            assertEqual(hash, expected0)

            let tree = try space.createIndex(name: "tree")
            let expected1 = Index(
                spaceId: space.id,
                id: 1,
                name: "tree",
                type: .tree,
                unique: true,
                source: iproto)
            assertEqual(tree, expected1)

            let rtree = try space.createIndex(name: "rtree", type: .rtree)
            let expected2 = Index(
                spaceId: space.id,
                id: 2,
                name: "rtree",
                type: .rtree,
                source: iproto)
            assertEqual(rtree, expected2)

            let nonUnique = try space.createIndex(name: "non_unique", unique: false)
            let expected3 = Index(
                spaceId: space.id,
                id: 3,
                name: "non_unique",
                type: .tree,
                source: iproto)
            assertEqual(nonUnique, expected3)
        } catch {
            fail(String(describing: error))
        }
    }

    func testCount() {
        do {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            let result = try index.count(iterator: .all)
            assertEqual(result, 3)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            let expected: [IProtoTuple] = [
                IProtoTuple([1, "foo"]),
                IProtoTuple([2, "bar"]),
                IProtoTuple([3, "baz"])
            ]
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            let result = try index.select(iterator: .all)
            assertEqual([IProtoTuple](result), expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testGet() {
        do {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            guard let result = try index.get(keys: [3]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProtoTuple([3, "baz"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.insert([4, "quux"])
            guard let result = try index.get(keys: [4]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProtoTuple([4, "quux"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.replace([3, "zab"])
            guard let result = try index.get(keys: [3]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProtoTuple([3, "zab"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.delete(keys: [3])
            assertNil(try index.get(keys: [3]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.update(keys: [3], operations: [["=", 1, "zab"]])
            guard let result = try index.get(keys: [3]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProtoTuple([3, "zab"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            assertNil(try index.get(keys: [4]))

            try index.upsert([4, "quux", 42], operations: [["+", 2, 8]])
            guard let insertResult = try index.get(keys: [4]) else {
                fail("tuple not found")
                return
            }
            assertEqual(insertResult, IProtoTuple([4, "quux", 42]))

            try index.upsert([4, "quux", 42], operations: [["+", 2, 8]])
            guard let updateResult = try index.get(keys: [4]) else {
                fail("tuple not found")
                return
            }
            assertEqual(updateResult, IProtoTuple([4, "quux", 50]))
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
        ("testCount", testCount),
        ("testSelect", testSelect),
        ("testGet", testGet),
        ("testInsert", testInsert),
        ("testReplace", testReplace),
        ("testDelete", testDelete),
        ("testUpdate", testUpdate),
        ("testUpsert", testUpsert),
    ]
}
