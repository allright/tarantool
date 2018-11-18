/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

import Platform
import MessagePack
import TarantoolModule

struct BoxTransactionTests {
    private static var space: Space<Box> = {
        let schema = try! Schema(Box())
        let space = try! schema.createSpace(name: "transaction_test")
        try! space.createIndex(name: "hash", type: .hash)
        return space
    }()

    static func testCommit() throws {
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

    static func testRollback() throws {
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

    static func testTCommit() throws {
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

    static func testTRollback() throws {
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

@_silgen_name("BoxTransactionTests_testCommit")
public func BoxTransactionTests_testCommit(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxTransactionTests.testTCommit()
    }
}

@_silgen_name("BoxTransactionTests_testRollback")
public func BoxTransactionTests_testRollback(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxTransactionTests.testRollback()
    }
}

@_silgen_name("BoxTransactionTests_testTCommit")
public func BoxTransactionTests_testTCommit(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxTransactionTests.testTCommit()
    }
}

@_silgen_name("BoxTransactionTests_testTRollback")
public func BoxTransactionTests_testTRollback(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxTransactionTests.testTRollback()
    }
}
