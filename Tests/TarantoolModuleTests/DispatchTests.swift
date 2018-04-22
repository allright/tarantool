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

class DispatchTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testSyncTask() {
        TarantoolProcess.testProcedure("DispatchTests_testSyncTask")
    }
}
