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
    public let code: Int?
    public let message: String
}

extension LuaError {
    init(message: String) {
        self.code = nil
        self.message = message
    }
}

extension LuaError {
    fileprivate init(_ L: OpaquePointer) {
        // standart lua error
        if let pointer = _lua_tolstring(L, -1, nil) {
            self.code = nil
            self.message = String(cString: pointer)
            return
        }

        // tarantool error
        if let errorPointer = _box_error_last(),
            let messagePointer = _box_error_message(errorPointer) {
            self.code = Int(_box_error_code(errorPointer))
            self.message = String(cString: messagePointer)
            return
        }

        self.code = nil
        self.message = "unknown"
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
        return try withNewStack { L in
            guard _luaL_loadbuffer(
                L, expression, expression.utf8.count, "=eval") == 0 else {
                    throw LuaError(L)
            }
            _luaL_checkstack(L, Int32(arguments.count), "eval: out of stack")
            try push(values: arguments, to: L)
            guard _luaT_call(L, Int32(arguments.count), LUA_MULTRET) == 0 else {
                throw LuaError(L)
            }
            return try popValues(from: L)
        }
    }

    public static func withNewStack<T>(
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

    public static func push(
        values: [MessagePack],
        to L: OpaquePointer
    ) throws {
        for value in values {
            try push(value: value, to: L)
        }
    }

    public static func push(value: MessagePack, to L: OpaquePointer) throws {
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
            throw LuaError(message: "argument type \(value) is not supported")
        }
    }

    public static func popValues(
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
            throw LuaError(message: "return type \(type) is not supported")
        }
    }

    public static func popFirst(from L: OpaquePointer) throws -> MessagePack? {
        let top = _lua_gettop(L)
        guard top > 0 else {
            return nil
        }
        let result = try pop(from: L, at: 1)
        _lua_remove(L, 1)
        return result
    }

    public static func popLast(from L: OpaquePointer) throws -> MessagePack? {
        let top = _lua_gettop(L)
        guard top > 0 else {
            return nil
        }
        let result = try pop(from: L, at: top)
        _lua_settop(L, -1)
        return result
    }
}
