import Test
import File
import Fiber
@testable import Async
@testable import TestUtils

class DispatchTests: TestCase {
    let temp = Path("/tmp/DispatchTests")

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

    func testSyncTask() {
        test("DispatchTests_testSyncTask")
    }
}
