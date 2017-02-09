/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import MessagePack
@testable import TarantoolModule

struct BoxSpaceTests {
    fileprivate static var testId: Int {
        return Int(try! Box.getSpaceIdByName([UInt8]("test".utf8)))
    }

    fileprivate static var space: Space {
        return Space(id: testId, source: BoxDataSource())
    }

    static func testCount() throws {
        let result = try space.count(.all)
        guard result == 3 else {
            throw "3 is not equal to \(result)"
        }
    }

    static func testSelect() throws {
        let result = try space.select(.all)
        guard result.count == 3 else {
            throw "3 is not equal to \(result)"
        }
    }

    static func testGet() throws {
        let result = try space.get([3])
        guard let tuple = result, tuple == [3, "baz"] else {
            throw "\(String(describing: result)) is not equal to [3, 'baz']"
        }
    }

    static func testInsert() throws {
        try space.insert([4, "quux"])
        let result = try space.get([4])
        guard let tuple = result, tuple == [4, "quux"] else {
            throw "\(String(describing: result))  is not equal to [4, 'quux']"
        }
    }

    static func testReplace() throws {
        try space.replace([3, "zab"])
        let result = try space.get([3])
        guard let tuple = result, tuple == [3, "zab"] else {
            throw "\(String(describing: result))  is not equal to [3, 'zab']"
        }
    }

    static func testDelete() throws {
        try space.delete([3])
        let result = try space.get([3])
        guard result == nil else {
            throw "\(String(describing: result)) is not nil"
        }
    }

    static func testUpdate() throws {
        try space.update([3], ops: [["=", 1, "zab"]])
        let result = try space.get([3])
        guard let tuple = result, tuple == [3, "zab"] else {
            throw "\(String(describing: result)) is not equal to [3, 'zab']"
        }
    }

    static func testUpsert() throws {
        let expectedNil = try space.get([4])
        guard expectedNil == nil else {
            throw "\(String(describing: expectedNil)) is not nil"
        }

        try space.upsert([4, "quux", 42], ops: [["+", 2, 8]])
        let insert = try space.get([4])

        guard let insertResult = insert, insertResult == [4, "quux", 42] else {
            throw "\(String(describing: insert)) is not equal to [4, 'quux', 42]"
        }

        try space.upsert([4, "quux", 42], ops: [["+", 2, 8]])
        let update = try space.get([4])

        guard let updateResult = update, updateResult == [4, "quux", 50] else {
            throw "\(String(describing: update)) is not equal to [4, 'quux', 50]"
        }
    }
}

// C API Wrappers

@_silgen_name("BoxSpaceTests_testCount")
public func BoxSpaceTests_testCount(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testCount()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceTests_testSelect")
public func BoxSpaceTests_testSelect(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testSelect()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceTests_testGet")
public func BoxSpaceTests_testGet(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testGet()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceTests_testInsert")
public func BoxSpaceTests_testInsert(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testInsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceTests_testReplace")
public func BoxSpaceTests_testReplace(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testReplace()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceTests_testDelete")
public func BoxSpaceTests_testDelete(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testDelete()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceTests_testUpdate")
public func BoxSpaceTests_testUpdate(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testUpdate()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxSpaceTests_testUpsert")
public func BoxSpaceTests_testUpsert(context: BoxContext) -> BoxResult {
    do {
        try BoxSpaceTests.testUpsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}
