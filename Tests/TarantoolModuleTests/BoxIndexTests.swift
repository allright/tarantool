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

class BoxIndexTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testHash() {
        TarantoolProcess.testProcedure("BoxIndexTests_testHash")
    }

    func testTree() {
        TarantoolProcess.testProcedure("BoxIndexTests_testTree")
    }

    func testRTree() {
        TarantoolProcess.testProcedure("BoxIndexTests_testRTree")
    }

    func testBitset() {
        TarantoolProcess.testProcedure("BoxIndexTests_testBitset")
    }

    func testSequence() {
        TarantoolProcess.testProcedure("BoxIndexTests_testSequence")
    }

    func testMany() {
        TarantoolProcess.testProcedure("BoxIndexTests_testMany")
    }

    func testCount() {
        TarantoolProcess.testProcedure("BoxIndexTests_testCount")
    }

    func testSelect() {
        TarantoolProcess.testProcedure("BoxIndexTests_testSelect")
    }

    func testGet() {
        TarantoolProcess.testProcedure("BoxIndexTests_testGet")
    }

    func testInsert() {
        TarantoolProcess.testProcedure("BoxIndexTests_testInsert")
    }

    func testReplace() {
        TarantoolProcess.testProcedure("BoxIndexTests_testReplace")
    }

    func testDelete() {
        TarantoolProcess.testProcedure("BoxIndexTests_testDelete")
    }

    func testUpdate() {
        TarantoolProcess.testProcedure("BoxIndexTests_testUpdate")
    }

    func testUpsert() {
        TarantoolProcess.testProcedure("BoxIndexTests_testUpsert")
    }
}
