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

class BoxTransactionTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testCommit() {
        TarantoolProcess.testProcedure("BoxTransactionTests_testCommit")
    }

    func testRollback() {
        TarantoolProcess.testProcedure("BoxTransactionTests_testRollback")
    }

    func testTCommit() {
        TarantoolProcess.testProcedure("BoxTransactionTests_testTCommit")
    }

    func testTRollback() {
        TarantoolProcess.testProcedure("BoxTransactionTests_testTRollback")
    }
}
