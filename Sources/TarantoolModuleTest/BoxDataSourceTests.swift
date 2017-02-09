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

struct BoxDataSourceTests {
    fileprivate static var testId: Int {
        return Int(try! Box.getSpaceIdByName([UInt8]("test".utf8)))
    }

    fileprivate static var source: BoxDataSource {
        return BoxDataSource()
    }

    static func testCount() throws {
        let result = try source.count(spaceId: testId, iterator: .all)
        guard result == 3 else {
            throw "3 is not equal to \(result)"
        }
    }

    static func testSelect() throws {
        let result = try source.select(spaceId: testId, iterator: .all)
        guard result.count == 3 else {
            throw "3 is not equal to \(result)"
        }
    }

    static func testGet() throws {
        let result = try source.get(spaceId: testId, keys: [3])
        guard let tuple = result, tuple == [3, "baz"] else {
            throw "\(String(describing: result)) is not equal to [3, 'baz']"
        }
    }

    static func testInsert() throws {
        try source.insert(spaceId: testId, tuple: [4, "quux"])
        let result = try source.get(spaceId: testId, keys: [4])
        guard let tuple = result, tuple == [4, "quux"] else {
            throw "\(String(describing: result))  is not equal to [4, 'quux']"
        }
    }

    static func testReplace() throws {
        try source.replace(spaceId: testId, tuple: [3, "zab"])
        let result = try source.get(spaceId: testId, keys: [3])
        guard let tuple = result, tuple == [3, "zab"] else {
            throw "\(String(describing: result))  is not equal to [3, 'zab']"
        }
    }

    static func testDelete() throws {
        try source.delete(spaceId: testId, keys: [3])
        let result = try source.get(spaceId: testId, keys: [3])
        guard result == nil else {
            throw "\(String(describing: result)) is not nil"
        }
    }

    static func testUpdate() throws {
        try source.update(spaceId: testId, keys: [3], ops: [["=", 1, "zab"]])
        let result = try source.get(spaceId: testId, keys: [3])
        guard let tuple = result, tuple == [3, "zab"] else {
            throw "\(String(describing: result)) is not equal to [3, 'zab']"
        }
    }

    static func testUpsert() throws {
        let expectedNil = try source.get(spaceId: testId, keys: [4])
        guard expectedNil == nil else {
            throw "\(String(describing: expectedNil)) is not nil"
        }

        try source.upsert(spaceId: testId, tuple: [4, "quux", 42], ops: [["+", 2, 8]])
        let insert = try source.get(spaceId: testId, keys: [4])

        guard let insertResult = insert, insertResult == [4, "quux", 42] else {
            throw "\(String(describing: insert)) is not equal to [4, 'quux', 42]"
        }

        try source.upsert(spaceId: testId, tuple: [4, "quux", 42], ops: [["+", 2, 8]])
        let update = try source.get(spaceId: testId, keys: [4])

        guard let updateResult = update, updateResult == [4, "quux", 50] else {
            throw "\(String(describing: update)) is not equal to [4, 'quux', 50]"
        }
    }
}

// C API Wrappers

@_silgen_name("BoxDataSourceTests_testCount")
public func BoxDataSourceTests_testCount(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testCount()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxDataSourceTests_testSelect")
public func BoxDataSourceTests_testSelect(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testSelect()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxDataSourceTests_testGet")
public func BoxDataSourceTests_testGet(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testGet()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxDataSourceTests_testInsert")
public func BoxDataSourceTests_testInsert(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testInsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxDataSourceTests_testReplace")
public func BoxDataSourceTests_testReplace(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testReplace()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxDataSourceTests_testDelete")
public func BoxDataSourceTests_testDelete(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testDelete()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxDataSourceTests_testUpdate")
public func BoxDataSourceTests_testUpdate(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testUpdate()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("BoxDataSourceTests_testUpsert")
public func BoxDataSourceTests_testUpsert(context: BoxContext) -> BoxResult {
    do {
        try BoxDataSourceTests.testUpsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}
