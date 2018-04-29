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

class BoxDataSourceTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testCount() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testCount")
    }

    func testSelect() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testSelect")
    }

    func testLimit() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testLimit")
    }

    func testGet() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testGet")
    }

    func testInsert() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testInsert")
    }

    func testReplace() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testReplace")
    }

    func testDelete() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testDelete")
    }

    func testUpdate() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testUpdate")
    }

    func testUpsert() {
        TarantoolProcess.testProcedure("BoxDataSourceTests_testUpsert")
    }
}
