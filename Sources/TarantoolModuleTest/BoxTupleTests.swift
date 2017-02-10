/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Platform
import Foundation
import MessagePack
@testable import TarantoolModule

struct BoxTupleTests {
    static func testUnpackTuple() throws {
        let boxTuple: [UInt8] = [
            // tuple header
            0x02, 0x00,
            0x13, 0x00,
            0x49, 0x00, 0x00, 0x00,
            0x0a, 0x00,
            // raw msgpack
            0x92,
            0x2a, 0xd9, 0x45, 0x41, 0x6e, 0x73, 0x77, 0x65,
            0x72, 0x20, 0x74, 0x6f, 0x20, 0x74, 0x68, 0x65,
            0x20, 0x55, 0x6c, 0x74, 0x69, 0x6d, 0x61, 0x74,
            0x65, 0x20, 0x51, 0x75, 0x65, 0x73, 0x74, 0x69,
            0x6f, 0x6e, 0x20, 0x6f, 0x66, 0x20, 0x4c, 0x69,
            0x66, 0x65, 0x2c, 0x20, 0x54, 0x68, 0x65, 0x20,
            0x55, 0x6e, 0x69, 0x76, 0x65, 0x72, 0x73, 0x65,
            0x2c, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x45, 0x76, 
            0x65, 0x72, 0x79, 0x74, 0x68, 0x69, 0x6e, 0x67
        ]

        let expected: Tuple = [42, "Answer to the Ultimate Question of Life, The Universe, and Everything"]

        let result = try Box.unpackTuple(OpaquePointer(boxTuple))

        guard result == expected else {
            throw "\(result) is not equal to \(expected)"
        }
    }
}

// C API Wrappers

@_silgen_name("BoxTupleTests_testUnpackTuple")
public func BoxTupleTests_testUnpackTuple(context: BoxContext) -> BoxResult {
    do {
        try BoxTupleTests.testUnpackTuple()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}
