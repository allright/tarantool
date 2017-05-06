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
import MessagePack

public struct LuaError: Error {
    let function: String = #function
    let file: String = #file
    let line: Int = #line

    let message: String
}

extension LuaError {
    fileprivate init(_ L: OpaquePointer) {
        guard let pointer = _lua_tolstring(L, -1, nil) else {
            self.message = "unknown"
            return
        }
        self.message = String(cString: pointer)
    }
}

public struct Lua {
    public static func call(
        _ function: String,
        _ arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        // TODO:
        throw LuaError(message: "call is not yet implemented")
    }

    public static func eval(
        _ expression: String,
        _ arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try withLuaStack { L in
            guard _luaL_loadbuffer(
                L, expression, expression.utf8.count, "=eval") == 0 else {
                    throw LuaError(L)
            }
            _luaL_checkstack(L, Int32(arguments.count), "eval: out of stack")
            try push(values: arguments, to: L)
            guard _luaT_call(L, Int32(arguments.count), LUA_MULTRET) == 0 else {
                throw LuaError(message: "eval: failed")
            }
            return try popValues(from: L)
        }
    }

    private static func withLuaStack<T>(
        _ task: (OpaquePointer) throws -> T
    ) throws -> T {
        let tarantool_L = _luaT_state()!
        guard let L = _lua_newthread(tarantool_L) else {
            throw LuaError(tarantool_L)
        }
        let coro_ref = _luaL_ref(tarantool_L, LUA_REGISTRYINDEX)
        defer { _luaL_unref(tarantool_L, LUA_REGISTRYINDEX, coro_ref) }
        return try task(L)
    }

    private static func push(
        values: [MessagePack],
        to L: OpaquePointer
    ) throws {
        for value in values {
            try push(value: value, to: L)
        }
    }

    private static func push(value: MessagePack, to L: OpaquePointer) throws {
        switch value {
        case .nil:
            _lua_pushnil(L)
        case .bool(let value):
            _lua_pushboolean(L, value ? 1 : 0)
        case .int(let value):
            _lua_pushnumber(L, Double(value))
        case .uint(let value):
            _lua_pushnumber(L, Double(value))
        case .float(let value):
            _lua_pushnumber(L, Double(value))
        case .double(let value):
            _lua_pushnumber(L, value)
        case .string(let value):
            _lua_pushstring(L, value)
        case .array(let array):
            let count = Int32(array.count)
            _lua_createtable(L, count, 0)
            for i in 1...count {
                try push(value: value, to: L)
                _lua_rawseti(L, -2, i)
            }
        case .map(let map):
            let count = Int32(map.count)
            _lua_createtable(L, 0, count)
            for (key, value) in map {
                try push(value: key, to: L)
                try push(value: value, to: L)
                _lua_settable(L, -3)
            }
        default:
            throw LuaError(message: "[push] type \(value) is not implemented")
        }
    }

    private static func popValues(
        from L: OpaquePointer
    ) throws -> [MessagePack] {
        let top = _lua_gettop(L)
        guard top > 0 else {
            return []
        }
        var result = [MessagePack]()
        for i in 1...top {
            result.append(try pop(from: L, at: i))
        }
        return result
    }

    private static func pop(
        from L: OpaquePointer,
        at index: Int32
    ) throws -> MessagePack {
        let type = _lua_type(L, index)
        switch type {
        case LUA_TNIL:
            return .nil
        case LUA_TNUMBER:
            let double = _lua_tonumber(L, index)
            guard double.truncatingRemainder(dividingBy: 1) != 0 else {
                return .int(_lua_tointeger(L, index))
            }
            return .double(double)
        case LUA_TBOOLEAN:
            return .bool(_lua_toboolean(L, index) == 1)
        case LUA_TSTRING:
            let pointer = _lua_tolstring(L, index, nil)!
            return .string(String(cString: pointer))
        case LUA_TTABLE:
            var map = Map()
            _lua_pushnil(L)
            while _lua_next(L, index) != 0 {
                _lua_pushvalue(L, -2)
                let key = try pop(from: L, at: _lua_gettop(L))
                _lua_settop(L, -2)
                let value = try pop(from: L, at: _lua_gettop(L))
                _lua_settop(L, -2)
                map[key] = value
            }
            return .map(map)
        default:
            throw LuaError(message: "[pop] type \(type) is not implemented")
        }
    }
}
