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
