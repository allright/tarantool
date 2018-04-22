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

class IProtoIteratorTests: TestCase {
    var tarantool: TarantoolProcess!
    var source: IProto!
    var testSpaceId = 0

    override func setUp() {
        async.setUp(Fiber.self)
        async.task {
            scope {
                let tarantool = try TarantoolProcess()
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                let result = try iproto.eval("return box.space.test.id")
                guard let testSpaceId = result.first?.integerValue else {
                    throw "can't get test space id"
                }
                self.tarantool = tarantool
                self.source = iproto
                self.testSpaceId = testSpaceId
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

    func withNewIProtoConnection(
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ body: @escaping (IProto) throws -> Void)
    {
        async.task {
            scope(file: file, line: line) {
                try body(self.source)
            }
        }
        async.loop.run()
    }

    func testSelectAll() {
        withNewIProtoConnection { source in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"]),
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            let spaceId = self.testSpaceId
            let result = try source.select(spaceId, 0, .all, [], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectEQ() {
        withNewIProtoConnection { source in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([2, "bar"])
            ]
            let spaceId = self.testSpaceId
            let result = try source.select(spaceId, 0, .eq, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)

        }
    }

    func testSelectGT() {
        withNewIProtoConnection { source in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([3, "baz"])
            ]
            let spaceId = self.testSpaceId
            let result = try source.select(spaceId, 0, .gt, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectGE() {
        withNewIProtoConnection { source in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            let spaceId = self.testSpaceId
            let result = try source.select(spaceId, 0, .ge, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectLT() {
        withNewIProtoConnection { source in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"])
            ]
            let spaceId = self.testSpaceId
            let result = try source.select(spaceId, 0, .lt, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectLE() {
        withNewIProtoConnection { source in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([1, "foo"])
            ]
            let spaceId = self.testSpaceId
            let result = try source.select(spaceId, 0, .le, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }
}
