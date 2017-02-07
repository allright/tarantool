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
import Foundation
@testable import TarantoolConnector

class CHAPSHA1Tests: XCTestCase {
    func testCHAPSHA1() {
        let data: [UInt8] = [0x74, 0x65, 0x73, 0x74, 0x65, 0x72]

        let salt: [UInt8] = [0x54, 0xe0, 0x4d, 0x6d, 0x92, 0x80, 0x74, 0x46,
                             0x2f, 0xdb, 0x1a, 0x1c, 0x15, 0x25, 0x2b, 0x3f,
                             0x9f, 0xa9, 0x0e, 0xad, 0x61, 0xc8, 0xd9, 0x30,
                             0xf0, 0x00, 0x81, 0x31, 0x80, 0x3c, 0x28, 0x89]

        let expected: [UInt8] = [0xed, 0xe7, 0xe3, 0xfe, 0xb0, 0x25, 0x01, 0x86,
                                 0xce, 0x8c, 0xa4, 0x8a, 0x6b, 0x7f, 0x4e, 0xc0,
                                 0x3a, 0xa7, 0x2a, 0xfc]

        let result = data.chapSha1(salt: salt)
        XCTAssertEqual(expected, result)
    }


    static var allTests : [(String, (CHAPSHA1Tests) -> () throws -> Void)] {
        return [
            ("testCHAPSHA1", testCHAPSHA1),
        ]
    }
}
