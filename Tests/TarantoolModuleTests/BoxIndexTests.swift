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
