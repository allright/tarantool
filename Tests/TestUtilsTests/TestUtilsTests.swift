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

class TestUtilsTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testTarantoolProcess() {
        async.task {
            scope {
                let tarantool = try TarantoolProcess()
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

    func testTempFolder() {
        async.task {
            scope {
                let tarantool = try TarantoolProcess()
                assertEqual(tarantool.temp, tarantool.temp)

                let tarantool2 = try TarantoolProcess()
                assertNotEqual(tarantool.temp, tarantool2.temp)
            }
        }
        async.loop.run()
    }

    func testModulePath() {
        guard let path = Module("TarantoolModuleTest").path else {
            fail()
            return
        }
        assertTrue(File.isExists(at: Path(string: path)))
    }
}
