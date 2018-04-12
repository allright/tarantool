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
import Fiber
@testable import Async
@testable import TestUtils
@testable import Tarantool
@testable import TarantoolConnector

class IProtoIndexTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

     func withNewIProtoSchema(
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ body: @escaping (Schema<IProto>) throws -> Void)
    {
        async.task {
            scope(file: file, line: line) {
                let tarantool = try TarantoolProcess()
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                try iproto.auth(username: "admin", password: "admin")

                let schema = try Schema(iproto)

                try body(schema)
            }
        }
        async.loop.run()
    }

    func testHash() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "test_hash")

            let hash = try space.createIndex(name: "hash", type: .hash)
            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "hash",
                type: .hash,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: schema.source)
            assertEqual(hash, expected)
        }
    }

    func testTree() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "test_tree")

            let tree = try space.createIndex(name: "tree", type: .tree)
            let expected = Index(
                spaceId: space.id,
                id: 0,
                name: "tree",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: schema.source)
            assertEqual(tree, expected)
        }
    }

    func testRTree() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "test_rtree")

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
                source: schema.source)
            assertEqual(rtree, expected)
        }
    }

    func testBitset() {
       withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "test_bitset")

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
                source: schema.source)
            assertEqual(rtree, expected)
        }
    }

    func testSequence() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "test_sequence")

            let primary = try space.createIndex(
                name: "primary", type: .hash, sequence: true)
            let expected = Index(
                spaceId: space.id,
                id: 0, name: "primary",
                type: .hash,
                sequenceId: 1,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: schema.source)
            assertEqual(primary.id, expected.id)
            // FIXME: crash on index.parts
            // assertEqual(primary, expected)
        }
    }

    func testMany() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "test_indexes")

            let hash = try space.createIndex(name: "hash", type: .hash)
            let expected0 = Index(
                spaceId: space.id,
                id: 0,
                name: "hash",
                type: .hash,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: schema.source)
            assertEqual(hash, expected0)

            let tree = try space.createIndex(name: "tree")
            let expected1 = Index(
                spaceId: space.id,
                id: 1,
                name: "tree",
                type: .tree,
                unique: true,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: schema.source)
            assertEqual(tree, expected1)

            let rtree = try space.createIndex(name: "rtree", type: .rtree)
            let expected2 = Index(
                spaceId: space.id,
                id: 2,
                name: "rtree",
                type: .rtree,
                parts: [Index.Part(field: 2, type: .array)],
                source: schema.source)
            assertEqual(rtree, expected2)

            let nonUnique = try space.createIndex(name: "non_unique", unique: false)
            let expected3 = Index(
                spaceId: space.id,
                id: 3,
                name: "non_unique",
                type: .tree,
                parts: [Index.Part(field: 1, type: .unsigned)],
                source: schema.source)
            assertEqual(nonUnique, expected3)
        }
    }

    func testCount() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            guard let index = space?[index: 0] else {
                fail("index not found")
                return
            }
            let result = try index.count(iterator: .all)
            assertEqual(result, 3)
        }
    }

    func testSelect() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"]),
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            guard let index = space?[index: 0] else {
                fail("index not found")
                return
            }
            let result = try index.select(iterator: .all)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testGet() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            guard let index = space?[index: 0] else {
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
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            guard let index = space?[index: 0] else {
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
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            guard let index = space?[index: 0] else {
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
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            guard let index = space?[index: 0] else {
                fail("index not found")
                return
            }
            try index.delete(keys: [3])
            assertNil(try index.get(keys: [3]))
        }
    }

    func testUpdate() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            guard let index = space?[index: 0] else {
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
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]

            guard let index = space?[index: 0] else {
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
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "temp")

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }

    func testIntegerPartType() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "temp")

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }

    func testNumberPartType() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "temp")

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }

    func testStringPartType() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "temp")

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }

    func testBooleanPartType() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "temp")

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }

    func testArrayPartType() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "temp")

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }

    func testScalarPartType() {
        withNewIProtoSchema { schema in
            let space = try schema.createSpace(name: "temp")

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }

    func testUppercased() {
        withNewIProtoSchema { schema in
            _ = try schema.source
                .eval("local temp=box.schema.space.create('temp');" +
                    "temp:create_index('primary', {type = 'TREE'})")
            try schema.update()

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
                source: schema.source)

            assertEqual(index, expected)
        }
    }
}
