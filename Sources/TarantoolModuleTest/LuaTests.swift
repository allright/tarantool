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
import MessagePack

struct LuaTests {
    static func testEval() throws {
        let null = try Lua.eval("return nil")
        try assertEqualThrows(null, [.nil])

        let answer = try Lua.eval("return 40 + 2")
        try assertEqualThrows(answer, [.int(42)])

        let negative = try Lua.eval("return 7 - 8")
        try assertEqualThrows(negative, [.int(-1)])

        let pi = try Lua.eval("return 3.14")
        try assertEqualThrows(pi, [.double(3.14)])

        let id = try Lua.eval("return box.space._vindex.id")
        try assertEqualThrows(id, [.int(289)])

        let arguments = try Lua.eval("""
            local name, value = ...
            local result = {}
            result[name] = value
            return result
            """, [.string("answer"), .int(42)])
        try assertEqualThrows(arguments, [.map([.string("answer") : .int(42)])])

        let empty = try Lua.eval("local var = 'empty stack'")
        try assertEqualThrows(empty, [])
    }

    static func testPushPop() throws {
        try Lua.withNewStack { lua in
            try lua.push(.int(1))
            try lua.push(.int(2))
            try lua.push(.int(3))

            guard let one = try lua.popFirst() else {
                throw "value not found"
            }
            try assertEqualThrows(one, .int(1))

            guard let three = try lua.popLast() else {
                throw "value not found"
            }
            try assertEqualThrows(three, .int(3))
        }
    }

    static func testPushPopMany() throws {
        try Lua.withNewStack { lua in
            try lua.push(values: [.int(1), .int(2), .int(3)])
            let one2Three = try lua.popValues()
            try assertEqualThrows(one2Three, [.int(1), .int(2), .int(3)])
        }
    }

    static func testPushPopArray() throws {
        try Lua.withNewStack { lua in
            try lua.push(.array([.int(1), .int(2), .int(3)]))
            guard let array = try lua.popLast() else {
                throw "value not found"
            }
            try assertEqualThrows(array, .array([.int(1), .int(2), .int(3)]))
        }
    }

    static func testPushPopMap() throws {
        try Lua.withNewStack { lua in
            try lua.push(.map([.int(1): .int(2), .int(3): .int(4)]))
            guard let map = try lua.popLast() else {
                throw "value not found"
            }
            try assertEqualThrows(map, .map(
                [.int(1): .int(2), .int(3): .int(4)]))
        }
    }
}

// C API Wrappers

@_silgen_name("LuaTests_testEval")
public func LuaTests_testEval(context: BoxContext) -> BoxResult {
    return Box.execute {
        try LuaTests.testEval()
    }
}

@_silgen_name("LuaTests_testPushPop")
public func LuaTests_testPushPop(context: BoxContext) -> BoxResult {
    return Box.execute {
        try LuaTests.testPushPop()
    }
}

@_silgen_name("LuaTests_testPushPopMany")
public func LuaTests_testPushPopMany(context: BoxContext) -> BoxResult {
    return Box.execute {
        try LuaTests.testPushPopMany()
    }
}

@_silgen_name("LuaTests_testPushPopArray")
public func LuaTests_testPushPopArray(context: BoxContext) -> BoxResult {
    return Box.execute {
        try LuaTests.testPushPopArray()
    }
}

@_silgen_name("LuaTests_testPushPopMap")
public func LuaTests_testPushPopMap(context: BoxContext) -> BoxResult {
    return Box.execute {
        try LuaTests.testPushPopMap()
    }
}
