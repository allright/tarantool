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

class BoxSpaceTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testCount() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testCount")
    }

    func testSelect() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testSelect")
    }

    func testGet() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testGet")
    }

    func testInsert() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testInsert")
    }

    func testReplace() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testReplace")
    }

    func testDelete() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testDelete")
    }

    func testUpdate() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testUpdate")
    }

    func testUpsert() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testUpsert")
    }

    func testSequence() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testSequence")
    }

    func testStoreIndex() {
        TarantoolProcess.testProcedure("BoxSpaceTests_testStoreIndex")
    }
}
