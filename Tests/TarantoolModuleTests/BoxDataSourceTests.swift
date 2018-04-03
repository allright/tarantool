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
