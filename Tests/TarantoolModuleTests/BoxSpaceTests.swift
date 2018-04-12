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
