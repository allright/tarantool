import Test
import File
import Fiber
@testable import Async
@testable import TestUtils
@testable import TarantoolConnector

class IProtoDataSourceTests: TestCase {
    let temp = Path("/tmp/IProtoDataSourceTests")

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
        async.task { [unowned self] in
            scope(file: file, line: line) {
                let path = self.temp.appending(function)
                let tarantool = try TarantoolProcess(at: path)
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                let result = try iproto.eval("return box.space.test.id")
                guard let testSpaceId = result.first?.integerValue else {
                    throw "can't get test space id"
                }
                try body(iproto, testSpaceId)
            }
        }
        async.loop.run()
    }

    func testCount() {
        withNewIProtoConnection { source, spaceId in
            let result = try source.count(spaceId, 0, .all, [])
            assertEqual(result, 3)
        }
    }

    func testSelect() {
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

    func testGet() {
        withNewIProtoConnection { source, spaceId in
            let result = try source.get(spaceId, 0, [3])
            assertEqual(result, IProto.Tuple([3, "baz"]))
        }
    }

    func testInsert() {
        withNewIProtoConnection { source, spaceId in
            try source.insert(spaceId, [4, "quux"])
            let result = try source.get(spaceId, 0, [4])
            assertEqual(result, IProto.Tuple([4, "quux"]))
        }
    }

    func testReplace() {
        withNewIProtoConnection { source, spaceId in
            try source.replace(spaceId, [3, "zab"])
            let result = try source.get(spaceId, 0, [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testDelete() {
        withNewIProtoConnection { source, spaceId in
            try source.delete(spaceId, 0, [3])
            assertNil(try source.get(spaceId, 0, [3]))
        }
    }

    func testUpdate() {
        withNewIProtoConnection { source, spaceId in
            try source.update(spaceId, 0, [3], [["=", 1, "zab"]])
            let result = try source.get(spaceId, 0, [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testUpsert() {
        withNewIProtoConnection { source, spaceId in
            assertNil(try source.get(spaceId, 0, [4]))

            try source.upsert(spaceId, 0, [4, "quux", 42], [["+", 2, 8]])
            let insertResult = try source.get(spaceId, 0, [4])
            assertEqual(insertResult, IProto.Tuple([4, "quux", 42]))

            try source.upsert(spaceId, 0, [4, "quux", 42], [["+", 2, 8]])
            let updateResult = try source.get(spaceId, 0, [4])
            assertEqual(updateResult, IProto.Tuple([4, "quux", 50]))
        }
    }
}
