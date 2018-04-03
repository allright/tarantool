/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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
