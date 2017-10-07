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

struct BoxSpaceTests {
    fileprivate static var space: Space<Box> {
        return try! Schema(Box()).spaces["test"]!
    }

    static func testCount() throws {
        let result = try space.count(.all)
        guard result == 3 else {
            throw "3 is not equal to \(result)"
        }
    }

    static func testSelect() throws {
        let expected: [[MessagePack]] = [[1, "foo"], [2, "bar"], [3, "baz"]]
        let result = try space.select(iterator: .all)
        let converted = [[MessagePack]](result)
        guard converted == expected else {
            throw "\(converted) is not equal to \(expected)"
        }
    }

    static func testGet() throws {
        let result = try space.get(keys: [3])
        guard let tuple = result, tuple.rawValue == [3, "baz"] else {
            throw "\(String(describing: result)) is not equal to [3, 'baz']"
        }
    }

    static func testInsert() throws {
        try space.insert([4, "quux"])
        let result = try space.get(keys: [4])
        guard let tuple = result, tuple.rawValue == [4, "quux"] else {
            throw "\(String(describing: result))  is not equal to [4, 'quux']"
        }
    }

    static func testReplace() throws {
        try space.replace([3, "zab"])
        let result = try space.get(keys: [3])
        guard let tuple = result, tuple.rawValue == [3, "zab"] else {
            throw "\(String(describing: result))  is not equal to [3, 'zab']"
        }
    }

    static func testDelete() throws {
        try space.delete(keys: [3])
        let result = try space.get(keys: [3])
        guard result == nil else {
            throw "\(String(describing: result)) is not nil"
        }
    }

    static func testUpdate() throws {
        try space.update(keys: [3], operations: [["=", 1, "zab"]])
        let result = try space.get(keys: [3])
        guard let tuple = result, tuple.rawValue == [3, "zab"] else {
            throw "\(String(describing: result)) is not equal to [3, 'zab']"
        }
    }

    static func testUpsert() throws {
        let expectedNil = try space.get(keys: [4])
        guard expectedNil == nil else {
            throw "\(String(describing: expectedNil)) is not nil"
        }

        try space.upsert([4, "quux", 42], operations: [["+", 2, 8]])
        let insert = try space.get(keys: [4])

        guard let insertResult = insert,
            insertResult.rawValue == [4, "quux", 42] else {
            throw String(describing: insert) +
                " is not equal to [4, 'quux', 42]"
        }

        try space.upsert([4, "quux", 42], operations: [["+", 2, 8]])
        let update = try space.get(keys: [4])

        guard let updateResult = update, updateResult.rawValue == [4, "quux", 50] else {
            throw String(describing: update) +
                " is not equal to [4, 'quux', 50]"
        }
    }
}

// C API Wrappers

@_silgen_name("BoxSpaceTests_testCount")
public func BoxSpaceTests_testCount(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testCount()
        return [true]
    }
}

@_silgen_name("BoxSpaceTests_testSelect")
public func BoxSpaceTests_testSelect(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testSelect()
        return [true]
    }
}

@_silgen_name("BoxSpaceTests_testGet")
public func BoxSpaceTests_testGet(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testGet()
        return [true]
    }
}

@_silgen_name("BoxSpaceTests_testInsert")
public func BoxSpaceTests_testInsert(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testInsert()
        return [true]
    }
}

@_silgen_name("BoxSpaceTests_testReplace")
public func BoxSpaceTests_testReplace(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testReplace()
        return [true]
    }
}

@_silgen_name("BoxSpaceTests_testDelete")
public func BoxSpaceTests_testDelete(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testDelete()
        return [true]
    }
}

@_silgen_name("BoxSpaceTests_testUpdate")
public func BoxSpaceTests_testUpdate(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testUpdate()
        return [true]
    }
}

@_silgen_name("BoxSpaceTests_testUpsert")
public func BoxSpaceTests_testUpsert(context: BoxContext) -> BoxResult {
    return Box.convertCall(context) {
        try BoxSpaceTests.testUpsert()
        return [true]
    }
}
