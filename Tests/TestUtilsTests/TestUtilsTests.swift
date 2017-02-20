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
import class Foundation.FileManager
@testable import TestUtils

class TestUtilsTests: TestCase {
    func testTarantoolProcess() {
        do {
            let tarantool = try TarantoolProcess()
            assertEqual(tarantool.isRunning, false)
            
            try tarantool.launch()
            assertEqual(tarantool.isRunning, true)
            
            let exitCode = tarantool.terminate()
            assertEqual(tarantool.isRunning, false)
            assertEqual(exitCode, 0)
        } catch {
            fail(String(describing: error))
        }
    }

    func testTempFolder() {
        do {
            let tarantool = try TarantoolProcess()
            assertEqual(tarantool.temp, tarantool.temp)
            
            let tarantool2 = try TarantoolProcess()
            assertNotEqual(tarantool.temp, tarantool2.temp)
        } catch {
            fail(String(describing: error))
        }
    }

    func testModulePath() {
        guard let path = Module("TarantoolModuleTest").path else {
            fail()
            return
        }
        assertTrue(FileManager.default.fileExists(atPath: path))
    }


    static var allTests : [(String, (TestUtilsTests) -> () throws -> Void)] {
        return [
            ("testTarantoolProcess", testTarantoolProcess),
            ("testTempFolder", testTempFolder),
            ("testModulePath", testModulePath),
        ]
    }
}
