import Test
import File
import Fiber
@testable import Async
@testable import TestUtils

class BoxSpaceTests: TestCase {
    let temp = Path("/tmp/BoxSpaceTests")

    override func setUp() {
        async.setUp(Fiber.self)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func test(
        _ name: String,
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ function: String = #function)
    {
        async.task { [unowned self] in
            scope(file: file, line: line) {
                let path = self.temp.appending(function)
                let tarantool = try TarantoolProcess(at: path, function: name)
                try tarantool.call(name)
            }
        }
        async.loop.run()
    }

    func testCount() {
        test("BoxSpaceTests_testCount")
    }

    func testSelect() {
        test("BoxSpaceTests_testSelect")
    }

    func testGet() {
        test("BoxSpaceTests_testGet")
    }

    func testInsert() {
        test("BoxSpaceTests_testInsert")
    }

    func testReplace() {
        test("BoxSpaceTests_testReplace")
    }

    func testDelete() {
        test("BoxSpaceTests_testDelete")
    }

    func testUpdate() {
        test("BoxSpaceTests_testUpdate")
    }

    func testUpsert() {
        test("BoxSpaceTests_testUpsert")
    }

    func testSequence() {
        test("BoxSpaceTests_testSequence")
    }

    func testStoreIndex() {
        test("BoxSpaceTests_testStoreIndex")
    }
}
