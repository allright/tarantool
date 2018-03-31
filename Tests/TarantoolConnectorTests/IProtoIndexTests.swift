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
@testable import Async
@testable import TestUtils
@testable import TarantoolConnector

class IProtoIndexTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProto!
    var space: Space<IProto>!

    override func setUp() {
        do {
            async.setUp(Dispatch.self)
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

            iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
            let schema = try Schema(iproto)
            self.space = schema.spaces["test"]
        } catch {
            continueAfterFailure = false
            fail(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testHash() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "test_hash")

            let hash = try space.createIndex(name: "hash", type: .hash)
            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "hash",
                type: .hash,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: iproto)
            assertEqual(hash, expected)
        }
    }

    func testTree() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "test_tree")

            let tree = try space.createIndex(name: "tree", type: .tree)
            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "tree",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: iproto)
            assertEqual(tree, expected)
        }
    }

    func testRTree() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
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
                parts: [Index.Part(field: 2, type: .array)],
                source: iproto)
            assertEqual(rtree, expected)
        }
    }

    func testBitset() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
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
                parts: [Index.Part(field: 2, type: .unsigned)],
                source: iproto)
            assertEqual(rtree, expected)
        }
    }

    func testSequence() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
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
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: iproto)
            assertEqual(primary, expected)
        }
    }

    func testMany() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            var schema = try Schema(iproto)

            var space = try schema.createSpace(name: "test_indexes")

            let hash = try space.createIndex(name: "hash", type: .hash)
            let expected0 = Index(
                spaceId: space.id,
                id: 0,
                name: "hash",
                type: .hash,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: iproto)
            assertEqual(hash, expected0)

            let tree = try space.createIndex(name: "tree")
            let expected1 = Index(
                spaceId: space.id,
                id: 1,
                name: "tree",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: iproto)
            assertEqual(tree, expected1)

            let rtree = try space.createIndex(name: "rtree", type: .rtree)
            let expected2 = Index(
                spaceId: space.id,
                id: 2,
                name: "rtree",
                type: .rtree,
                parts: [Index.Part(field: 2, type: .array)],
                source: iproto)
            assertEqual(rtree, expected2)

            let nonUnique = try space.createIndex(name: "non_unique", unique: false)
            let expected3 = Index(
                spaceId: space.id,
                id: 3,
                name: "non_unique",
                type: .tree,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: iproto)
            assertEqual(nonUnique, expected3)
        }
    }

    func testCount() {
        scope {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            let result = try index.count(iterator: .all)
            assertEqual(result, 3)
        }
    }

    func testSelect() {
        scope {
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"]),
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            let result = try index.select(iterator: .all)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testGet() {
        scope {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            guard let result = try index.get(keys: [3]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProto.Tuple([3, "baz"]))
        }
    }

    func testInsert() {
        scope {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.insert([4, "quux"])
            guard let result = try index.get(keys: [4]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProto.Tuple([4, "quux"]))
        }
    }

    func testReplace() {
        scope {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.replace([3, "zab"])
            guard let result = try index.get(keys: [3]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testDelete() {
        scope {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.delete(keys: [3])
            assertNil(try index.get(keys: [3]))
        }
    }

    func testUpdate() {
        scope {
            guard let index = space[index: 0] else {
                fail("index not found")
                return
            }
            try index.update(keys: [3], operations: [["=", 1, "zab"]])
            guard let result = try index.get(keys: [3]) else {
                fail("tuple not found")
                return
            }
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testUpsert() {
        scope {
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
            assertEqual(insertResult, IProto.Tuple([4, "quux", 42]))

            try index.upsert([4, "quux", 42], operations: [["+", 2, 8]])
            guard let updateResult = try index.get(keys: [4]) else {
                fail("tuple not found")
                return
            }
            assertEqual(updateResult, IProto.Tuple([4, "quux", 50]))
        }
    }

    func testUnsignedPartType() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "temp")

            let index = try space.createIndex(
                name: "unsigned",
                type: .tree,
                parts: [Index.Part(field: 1, type: .unsigned)])

            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "unsigned",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: iproto)

            assertEqual(index, expected)

        }
    }

    func testIntegerPartType() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "temp")

            let index = try space.createIndex(
                name: "integer",
                type: .tree,
                parts: [Index.Part(field: 1, type: .integer)])

            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "integer",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .integer)],
                source: iproto)

            assertEqual(index, expected)

        }
    }

    func testNumberPartType() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "temp")

            let index = try space.createIndex(
                name: "number",
                type: .tree,
                parts: [Index.Part(field: 1, type: .number)])

            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "number",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .number)],
                source: iproto)

            assertEqual(index, expected)

        }
    }

    func testStringPartType() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "temp")

            let index = try space.createIndex(
                name: "string",
                type: .tree,
                parts: [Index.Part(field: 1, type: .string)])

            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "string",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .string)],
                source: iproto)

            assertEqual(index, expected)

        }
    }

    func testBooleanPartType() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "temp")

            let index = try space.createIndex(
                name: "boolean",
                type: .tree,
                parts: [Index.Part(field: 1, type: .boolean)])

            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "boolean",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .boolean)],
                source: iproto)

            assertEqual(index, expected)

        }
    }

    func testArrayPartType() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "temp")

            try space.createIndex(name: "primary")

            let index = try space.createIndex(
                name: "array",
                type: .rtree,
                unique: false,
                parts: [Index.Part(field: 2, type: .array)])

            let expected = Index(
                spaceId: space.id,
                id: 1,
                name: "array",
                type: .rtree,
                unique: false,
                parts: [Index.Part(field: 2, type: .array)],
                source: iproto)

            assertEqual(index, expected)

        }
    }

    func testScalarPartType() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            var schema = try Schema(iproto)
            var space = try schema.createSpace(name: "temp")

            let index = try space.createIndex(
                name: "scalar",
                type: .tree,
                parts: [Index.Part(field: 1, type: .scalar)])

            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "scalar",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .scalar)],
                source: iproto)

            assertEqual(index, expected)

        }
    }

    func testUppercased() {
        scope {
            try iproto.auth(username: "admin", password: "admin")

            _ = try iproto.eval("local temp=box.schema.space.create('temp');" +
                "temp:create_index('primary', {type = 'TREE'})")

            let schema = try Schema(iproto)
            guard let space = schema.spaces["temp"] else {
                fail()
                return
            }

            guard let index = space[index: "primary"] else {
                fail()
                return
            }

            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "primary",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 0, type: .unsigned)],
                source: iproto)

            assertEqual(index, expected)

        }
    }
}
