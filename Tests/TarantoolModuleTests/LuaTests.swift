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

class LuaTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testEval() {
        TarantoolProcess.testProcedure("LuaTests_testEval")
    }

    func testPushPop() {
        TarantoolProcess.testProcedure("LuaTests_testPushPop")
    }

    func testPushPopMany() {
        TarantoolProcess.testProcedure("LuaTests_testPushPopMany")
    }

    func testPushPopArray() {
        TarantoolProcess.testProcedure("LuaTests_testPushPopArray")
    }

    func testPushPopMap() {
        TarantoolProcess.testProcedure("LuaTests_testPushPopMap")
    }
}
