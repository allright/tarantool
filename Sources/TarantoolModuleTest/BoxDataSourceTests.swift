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

extension String: Error {}

var testId: Int {
    guard let id = try? Box.getSpaceIdByName([UInt8]("test".utf8)) else {
        return 0
    }
    return Int(id)
}

var source: BoxDataSource {
    return BoxDataSource()
}

func testCount() throws {
    let result = try source.count(spaceId: testId, iterator: .all)
    guard result == 3 else {
        throw "3 is not equal to \(result)"
    }
}

func testSelect() throws {
    let result = try source.select(spaceId: testId, iterator: .all)
    guard result.count == 3 else {
        throw "3 is not equal to \(result)"
    }
}

func testGet() throws {
    let result = try source.get(spaceId: testId, keys: [3])
    guard let tuple = result, tuple == [3, "baz"] else {
        throw "\(String(describing: result)) is not equal to [3, 'baz']"
    }
}

func testInsert() throws {
    try source.insert(spaceId: testId, tuple: [4, "quux"])
    let result = try source.get(spaceId: testId, keys: [4])
    guard let tuple = result, tuple == [4, "quux"] else {
        throw "\(String(describing: result))  is not equal to [4, 'quux']"
    }
}

func testReplace() throws {
    try source.replace(spaceId: testId, tuple: [3, "zab"])
    let result = try source.get(spaceId: testId, keys: [3])
    guard let tuple = result, tuple == [3, "zab"] else {
        throw "\(String(describing: result))  is not equal to [3, 'zab']"
    }
}

func testDelete() throws {
    try source.delete(spaceId: testId, keys: [3])
    let result = try source.get(spaceId: testId, keys: [3])
    guard result == nil else {
        throw "\(String(describing: result)) is not nil"
    }
}

func testUpdate() throws {
    try source.update(spaceId: testId, keys: [3], ops: [["=", 1, "zab"]])
    let result = try source.get(spaceId: testId, keys: [3])
    guard let tuple = result, tuple == [3, "zab"] else {
        throw "\(String(describing: result)) is not equal to [3, 'zab']"
    }
}

func testUpsert() throws {
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

// C API Wrappers

@_silgen_name("testCount")
public func testCountShim(context: BoxContext) -> BoxResult {
    do {
        try testCount()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("testSelect")
public func testSelectShim(context: BoxContext) -> BoxResult {
    do {
        try testSelect()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("testGet")
public func testGetShim(context: BoxContext) -> BoxResult {
    do {
        try testGet()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("testInsert")
public func testInsertShim(context: BoxContext) -> BoxResult {
    do {
        try testInsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("testReplace")
public func testReplaceShim(context: BoxContext) -> BoxResult {
    do {
        try testReplace()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("testDelete")
public func testDeleteShim(context: BoxContext) -> BoxResult {
    do {
        try testDelete()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("testUpdate")
public func testUpdateShim(context: BoxContext) -> BoxResult {
    do {
        try testUpdate()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("testUpsert")
public func testUpsertShim(context: BoxContext) -> BoxResult {
    do {
        try testUpsert()
        return Box.returnTuple(nil, to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}
