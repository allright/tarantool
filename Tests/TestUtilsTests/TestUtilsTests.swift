import Test
import File
import Fiber
@testable import Async
@testable import TestUtils

class TestUtilsTests: TestCase {
    let temp = Path("/tmp/TestUtilsTests")

    override func setUp() {
        async.setUp(Fiber.self)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func testTarantoolProcess() {
        async.task {
            scope {
                let temp = self.temp.appending("tarantool_\(#function)")
                let tarantool = try TarantoolProcess(at: temp)
                assertEqual(tarantool.isRunning, false)

                try tarantool.launch()
                assertEqual(tarantool.isRunning, true)

                let exitCode = try tarantool.terminate()
                assertEqual(tarantool.isRunning, false)
                assertEqual(exitCode, 0)
            }
        }
        async.loop.run()
    }

    func testModulePath() {
        guard let path = Module("TarantoolModuleTest").path else {
            fail()
            return
        }
        assertTrue(File.isExists(at: Path(path)))
    }
}
