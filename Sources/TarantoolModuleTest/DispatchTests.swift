/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import CTarantool
import TarantoolModule

import struct Foundation.Date

struct DispatchTests {
    static func testSyncTask() throws {
        var iterations: Int = 0

        fiber {
            while iterations < 10 {
                // tick tock tick tock
                sleep(until: Date().addingTimeInterval(0.09))
                iterations += 1
            }
        }

        var result = 0
        var iterationsAtStart = 0
        var iterationsAfterOneSecond = 0

        do {
            result = try syncTask {
                iterationsAtStart = iterations
                // block thread
                sleep(1)
                iterationsAfterOneSecond = iterations
                return 42
            }
        } catch {
            throw error
        }

        try assertEqualThrows(result, 42)
        try assertEqualThrows(iterationsAtStart, 0)
        try assertEqualThrows(iterationsAfterOneSecond, 10)
    }
}

// C API Wrappers

@_silgen_name("DispatchTests_testSyncTask")
public func DispatchTests_testSyncTask(context: BoxContext) -> BoxResult {
    do {
        try DispatchTests.testSyncTask()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}
