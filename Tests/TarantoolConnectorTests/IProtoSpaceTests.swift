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

import Test
import Fiber
@testable import Async
@testable import TestUtils
@testable import TarantoolConnector

final class IProtoSpaceTests: TestCase {
    var tarantool: TarantoolProcess!
    var schema: Schema<IProto>!

    override func setUp() {
        async.setUp(Fiber.self)
        async.task {
            scope {
                let tarantool = try TarantoolProcess()
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                let schema = try Schema(iproto)
                self.tarantool = tarantool
                self.schema = schema
            }
        }
        async.loop.run()
    }

    override func tearDown() {
        async.task {
            assertEqual(try? self.tarantool.terminate(), 0)
        }
        async.loop.run()
    }

    func withNewIProtoSchema(
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ body: @escaping (Schema<IProto>) throws -> Void)
    {
        async.task {
            scope(file: file, line: line) {
                try body(self.schema)
            }
        }
        async.loop.run()
    }

    func testCount() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]
            let result = try space?.count(.all)
            assertEqual(result, 3)
        }
    }

    func testSelect() {
        withNewIProtoSchema { schema in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"]),
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            let space = schema.spaces["test"]!
            let result = try space.select(iterator: .all)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testGet() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]!
            let result = try space.get(keys: [3])
            assertEqual(result, IProto.Tuple([3, "baz"]))
        }
    }

    func testInsert() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]!
            try space.insert([4, "quux"])
            let result = try space.get(keys: [4])
            assertEqual(result, IProto.Tuple([4, "quux"]))
        }
    }

    func testReplace() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]!
            try space.replace([3, "zab"])
            let result = try space.get(keys: [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testDelete() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]!
            try space.delete(keys: [3])
            assertNil(try space.get(keys: [3]))
        }
    }

    func testUpdate() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]!
            try space.update(keys: [3], operations: [["=", 1, "zab"]])
            let result = try space.get(keys: [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testUpsert() {
        withNewIProtoSchema { schema in
            let space = schema.spaces["test"]!
            assertNil(try space.get(keys: [4]))

            try space.upsert([4, "quux", 42], operations: [["+", 2, 8]])
            let insertResult = try space.get(keys: [4])
            assertEqual(insertResult, IProto.Tuple([4, "quux", 42]))

            try space.upsert([4, "quux", 42], operations: [["+", 2, 8]])
            let updateResult = try space.get(keys: [4])
            assertEqual(updateResult, IProto.Tuple([4, "quux", 50]))
        }
    }

    func testSequence() {
        withNewIProtoSchema { schema in
            let seq = schema.spaces["seq"]!
            var id = try seq.insert([nil, "foo"])
            assertEqual(id, 1)

            id = try seq.insert([nil, "bar"])
            assertEqual(id, 2)

            let result = try seq.get(keys: [id])
            assertEqual(result, IProto.Tuple([2, "bar"]))
        }
    }
}
