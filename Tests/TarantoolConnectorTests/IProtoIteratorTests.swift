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
import File
import Fiber
@testable import Async
@testable import TestUtils
@testable import TarantoolConnector

class IProtoIteratorTests: TestCase {
    let temp = Path("/tmp/IProtoIteratorTests")

    override func setUp() {
        async.setUp(Fiber.self)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func withNewIProtoConnection(
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ function: String = #function,
        _ body: @escaping (IProto, Int) throws -> Void)
    {
        async.task {
            scope(file: file, line: line) {
                let path = self.temp.appending(function)
                let tarantool = try TarantoolProcess(at: path)
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                let result = try iproto.eval("return box.space.test.id")
                guard let testSpaceId = result.first?.integerValue else {
                    throw "can't get test space id"
                }
                try body(iproto, testSpaceId)
                assertEqual(try? tarantool.terminate(), 0)
            }
        }
        async.loop.run()
    }

    func testSelectAll() {
        withNewIProtoConnection { source, spaceId in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"]),
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            let result = try source.select(spaceId, 0, .all, [], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectEQ() {
        withNewIProtoConnection { source, spaceId in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([2, "bar"])
            ]
            let result = try source.select(spaceId, 0, .eq, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)

        }
    }

    func testSelectGT() {
        withNewIProtoConnection { source, spaceId in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([3, "baz"])
            ]
            let result = try source.select(spaceId, 0, .gt, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectGE() {
        withNewIProtoConnection { source, spaceId in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            let result = try source.select(spaceId, 0, .ge, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectLT() {
        withNewIProtoConnection { source, spaceId in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"])
            ]
            let result = try source.select(spaceId, 0, .lt, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testSelectLE() {
        withNewIProtoConnection { source, spaceId in
            let expected: [IProto.Tuple] = [
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([1, "foo"])
            ]
            let result = try source.select(spaceId, 0, .le, [2], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }
}
