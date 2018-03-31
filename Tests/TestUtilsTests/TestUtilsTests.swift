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
import File
import AsyncDispatch
@testable import Async
@testable import TestUtils

class TestUtilsTests: TestCase {
    override func setUp() {
        async.setUp(Dispatch.self)
    }

    func testTarantoolProcess() {
        scope {
            let tarantool = try TarantoolProcess()
            assertEqual(tarantool.isRunning, false)

            try tarantool.launch()
            assertEqual(tarantool.isRunning, true)

            let exitCode = tarantool.terminate()
            assertEqual(tarantool.isRunning, false)
            assertEqual(exitCode, 0)
        }
    }

    func testTempFolder() {
        scope {
            let tarantool = try TarantoolProcess()
            assertEqual(tarantool.temp, tarantool.temp)

            let tarantool2 = try TarantoolProcess()
            assertNotEqual(tarantool.temp, tarantool2.temp)
        }
    }

    func testModulePath() {
        guard let path = Module("TarantoolModuleTest").path else {
            fail()
            return
        }
        assertTrue(File.isExists(at: Path(string: path)))
    }
}
