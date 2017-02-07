/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import XCTest
@testable import TestUtils

class TestUtilsTests: XCTestCase {
    func testTarantoolProcess() {
        do {
            let tarantool = try TarantoolProcess()
            XCTAssertEqual(tarantool.isRunning, false)
            
            try tarantool.launch()
            XCTAssertEqual(tarantool.isRunning, true)
            
            let exitCode = tarantool.terminate()
            XCTAssertEqual(tarantool.isRunning, false)
            XCTAssertEqual(exitCode, 0)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testTempFolder() {
        do {
            let tarantool = try TarantoolProcess()
            XCTAssertEqual(tarantool.temp, tarantool.temp)
            
            let tarantool2 = try TarantoolProcess()
            XCTAssertNotEqual(tarantool.temp, tarantool2.temp)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testModulePath() {
        guard let path = Module("TarantoolModuleTest").path else {
            XCTFail()
            return
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    }


    static var allTests : [(String, (TestUtilsTests) -> () throws -> Void)] {
        return [
            ("testTarantoolProcess", testTarantoolProcess),
            ("testTempFolder", testTempFolder),
            ("testModulePath", testModulePath),
        ]
    }
}
