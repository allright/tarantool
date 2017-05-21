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
import TarantoolModule

struct BoxTransactionTests {
    fileprivate static var testId: Int = {
        return try! Schema(Box()).spaces["test"]!.id
    }()

    fileprivate static var space: Space = {
        return Space(id: testId, name: "test", source: Box())
    }()

    static func testTransactionCommit() throws {
        guard try space.count() == 0 else {
            throw "space is not empty"
        }

        try transaction {
            try space.insert([1, "one"])
            try space.insert([2, "two"])
            try space.insert([3, "three"])
        }

        let count = try space.count()
        guard count == 3 else {
            throw "\(count) is not equal to 3"
        }
    }

    static func testTransactionRollback() throws {
        guard try space.count() == 0 else {
            throw "space is not empty"
        }

        struct Rollback: Error {}

        try? transaction {
            try space.insert([1, "one"])
            try space.insert([2, "two"])
            try space.insert([3, "three"])
            throw Rollback()
        }

        let count = try space.count()
        guard count == 0 else {
            throw "\(count) is not equal to 0"
        }
    }

    static func testGenericTransactionCommit() throws {
        guard try space.count() == 0 else {
            throw "space is not empty"
        }

        let count: Int = try transaction {
            try space.insert([1, "one"])
            try space.insert([2, "two"])
            try space.insert([3, "three"])

            return try space.count()
        }

        guard count == 3 else {
            throw "\(count) is not equal to 3"
        }
    }

    static func testGenericTransactionRollback() throws {
        guard try space.count() == 0 else {
            throw "space is not empty"
        }

        struct Rollback: Error {}

        do {
            let count: Int = try transaction {
                try space.insert([1, "one"])
                try space.insert([2, "two"])
                try space.insert([3, "three"])

                if 10 % 2 == 0 {
                    throw Rollback()
                }

                return try space.count()
            }
            throw "unexpected result: \(count)"
        } catch where error is Rollback {
            let count = try space.count()

            guard count == 0 else {
                throw "\(count) is not equal to 0"
            }
        }
    }
}

// C API Wrappers

@_silgen_name("BoxTransactionTests_testTransactionCommit")
public func BoxTransactionTests_testTransactionCommit(context: BoxContext) -> BoxResult {
    do {
        try BoxTransactionTests.testTransactionCommit()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}

@_silgen_name("BoxTransactionTests_testTransactionRollback")
public func BoxTransactionTests_testTransactionRollback(context: BoxContext) -> BoxResult {
    do {
        try BoxTransactionTests.testTransactionRollback()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}

@_silgen_name("BoxTransactionTests_testGenericTransactionCommit")
public func BoxTransactionTests_testGenericTransactionCommit(context: BoxContext) -> BoxResult {
    do {
        try BoxTransactionTests.testGenericTransactionCommit()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}

@_silgen_name("BoxTransactionTests_testGenericTransactionRollback")
public func BoxTransactionTests_testGenericTransactionRollback(context: BoxContext) -> BoxResult {
    do {
        try BoxTransactionTests.testGenericTransactionRollback()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}
