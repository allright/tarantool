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
import TarantoolModule

struct BoxDataSourceTests {
    fileprivate static var testId: Int {
        return try! Schema(Box()).spaces["test"]!.id
    }

    fileprivate static var source: Box {
        return Box()
    }

    static func testCount() throws {
        let result = try source.count(testId, 0, .all, [])
        guard result == 3 else {
            throw "3 is not equal to \(result)"
        }
    }

    static func testSelect() throws {
        let expected: [[MessagePack]] = [[1, "foo"], [2, "bar"], [3, "baz"]]
        let result = try source.select(testId, 0, .all, [], 0, 1000)
        let converted = [[MessagePack]](result)
        guard converted == expected else {
            throw "\(converted) is not equal to \(expected)"
        }
    }

    static func testGet() throws {
        let result = try source.get(testId, 0, [3])
        guard let tuple = result, tuple.unpack() == [3, "baz"] else {
            throw "\(String(describing: result)) is not equal to [3, 'baz']"
        }
    }

    static func testInsert() throws {
        try source.insert(testId, [4, "quux"])
        let result = try source.get(testId, 0, [4])
        guard let tuple = result, tuple.unpack() == [4, "quux"] else {
            throw "\(String(describing: result))  is not equal to [4, 'quux']"
        }
    }

    static func testReplace() throws {
        try source.replace(testId, [3, "zab"])
        let result = try source.get(testId, 0, [3])
        guard let tuple = result, tuple.unpack() == [3, "zab"] else {
            throw "\(String(describing: result))  is not equal to [3, 'zab']"
        }
    }

    static func testDelete() throws {
        try source.delete(testId, 0, [3])
        let result = try source.get(testId, 0, [3])
        guard result == nil else {
            throw "\(String(describing: result)) is not nil"
        }
    }

    static func testUpdate() throws {
        try source.update(testId, 0, [3], [["=", 1, "zab"]])
        let result = try source.get(testId, 0, [3])
        guard let tuple = result, tuple.unpack()  == [3, "zab"] else {
            throw "\(String(describing: result)) is not equal to [3, 'zab']"
        }
    }

    static func testUpsert() throws {
        let expectedNil = try source.get(testId, 0, [4])
        guard expectedNil == nil else {
            throw "\(String(describing: expectedNil)) is not nil"
        }

        try source.upsert(testId, 0, [4, "quux", 42], [["+", 2, 8]])
        let insert = try source.get(testId, 0, [4])

        guard let insertResult = insert, insertResult.unpack() == [4, "quux", 42] else {
                throw "\(String(describing: insert)) is not equal to [4, 'quux', 42]"
        }

        try source.upsert(testId, 0, [4, "quux", 42], [["+", 2, 8]])
        let update = try source.get(testId, 0, [4])

        guard let updateResult = update, updateResult.unpack() == [4, "quux", 50] else {
            throw "\(String(describing: update)) is not equal to [4, 'quux', 50]"
        }
    }
}

// C API Wrappers

@_silgen_name("BoxDataSourceTests_testCount")
public func BoxDataSourceTests_testCount(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testCount()
    }
}

@_silgen_name("BoxDataSourceTests_testSelect")
public func BoxDataSourceTests_testSelect(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testSelect()
    }
}

@_silgen_name("BoxDataSourceTests_testGet")
public func BoxDataSourceTests_testGet(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testGet()
    }
}

@_silgen_name("BoxDataSourceTests_testInsert")
public func BoxDataSourceTests_testInsert(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testInsert()
    }
}

@_silgen_name("BoxDataSourceTests_testReplace")
public func BoxDataSourceTests_testReplace(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testReplace()
    }
}

@_silgen_name("BoxDataSourceTests_testDelete")
public func BoxDataSourceTests_testDelete(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testDelete()
    }
}

@_silgen_name("BoxDataSourceTests_testUpdate")
public func BoxDataSourceTests_testUpdate(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testUpdate()
    }
}

@_silgen_name("BoxDataSourceTests_testUpsert")
public func BoxDataSourceTests_testUpsert(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxDataSourceTests.testUpsert()
    }
}
