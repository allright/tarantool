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

extension Lua {
    // Allocates a new Lua thread on top of Taranool state.
    // This means that all Tarantool's modules/values are visible from it.
    public static func withNewStack<T>(
        _ task: (Lua) throws -> T
    ) throws -> T {
        let tarantool_L = _luaT_state()!
        guard let L = _lua_newthread(tarantool_L) else {
            throw Error(tarantool_L)
        }
        let coro_ref = _luaL_ref(tarantool_L, LUA_REGISTRYINDEX)
        defer { _luaL_unref(tarantool_L, LUA_REGISTRYINDEX, coro_ref) }
        return try task(Lua(stack: L))
    }
}

public struct Lua {
    public let L: OpaquePointer

    public init(stack L: OpaquePointer) {
        self.L = L
    }

    public var top: Int {
        get {
            return Int(_lua_gettop(L))
        }
        nonmutating set {
            _lua_settop(L, Int32(newValue))
        }
    }

    public typealias FieldType = Int32

    public func type(at index: Int) -> FieldType {
        return _lua_type(L, Int32(index))
    }

    public func pop(count: Int) {
        top = -(count + 1)
    }

    public func pushValue(at index: Int) {
        _lua_pushvalue(L, Int32(index))
    }

    public func remove(at index: Int) {
        _lua_remove(L, Int32(index))
    }

    public func createTable(
        arrayElementsCount: Int = 0,
        hashElementsCount: Int = 0
    ) {
        _lua_createtable(L, Int32(arrayElementsCount), Int32(hashElementsCount))
    }

    public func rawGet(fromTableAt index: Int) {
        _lua_rawget(L, Int32(index))
    }

    public func rawSet(toTableAt index: Int) {
        _lua_rawset(L, Int32(index))
    }

    public func rawGet(fromTableAt index: Int, at offset: Int) {
        _lua_rawgeti(L, Int32(index), Int32(offset))
    }

    public func rawSet(toTableAt index: Int, at offset: Int) {
        _lua_rawseti(L, Int32(index), Int32(offset))
    }

    public func next(at index: Int) -> Bool {
        return _lua_next(L, Int32(index)) != 0
    }

    public func checkStack(size: Int, error: String) {
        _luaL_checkstack(L, Int32(size), error)
    }

    public func setField(toTableAt index: Int, name: String) {
        _lua_setfield(L, Int32(index), name)
    }

    public func getField(fromTableAt index: Int, name: String) {
        _lua_getfield(L, Int32(index), name)
    }

    public func ref(inTableAt table: Int) -> Int {
        return Int(_luaL_ref(L, Int32(table)))
    }

    public func unref(inTableAt table: Int, ref: Int) {
        return _luaL_unref(L, Int32(table), Int32(ref))
    }

    public func getMetadataField(at index: Int, name: String) -> FieldType {
        return _luaL_getmetafield(L, Int32(index), name)
    }

    public func getMetatable(forTableAt index: Int) -> Int {
        return Int(_lua_getmetatable(L, Int32(index)))
    }

    public func setMetatable(forTableAt index: Int) {
        _ = _lua_setmetatable(L, Int32(index))
    }

    public func load(string: String) throws {
        guard _luaL_loadstring(L, string) == 0 else {
            throw Error(L)
        }
    }

    public func load(string: String, name: String) throws {
        try string.withCString { pointer in
            let count = strlen(pointer)
            guard _luaL_loadbuffer(L, pointer, count, name) == 0 else {
                throw Error(L)
            }
        }
    }

    public func call(
        argumentsCount: Int,
        returnCount: Int = Int(LUA_MULTRET)
    ) throws {
        guard _luaT_call(L, Int32(argumentsCount), Int32(returnCount)) == 0
            else {
                throw Error(L)
        }
    }
}

extension Lua {
    public enum Index: Int {
        case registry = -10000
        case environ = -10001
        case globals = -10002
    }

    public func getField(from index: Index, name: String) {
        getField(fromTableAt: index.rawValue, name: name)
    }

    public func ref(at index: Index) -> Int {
        return ref(inTableAt: index.rawValue)
    }

    public func rawGet(from index: Index) {
        rawGet(fromTableAt: index.rawValue)
    }

    public func rawSet(to index: Index) {
        rawSet(toTableAt: index.rawValue)
    }

    public func rawGet(from index: Index, at offset: Int) {
        rawGet(fromTableAt: index.rawValue, at: offset)
    }

    public func rawSet(to index: Index, at offset: Int) {
        rawSet(toTableAt: index.rawValue, at: offset)
    }
}

extension Lua {
    public func pushNil() {
        _lua_pushnil(L)
    }

    public func push(_ value: Bool) {
        _lua_pushboolean(L, value ? 1 : 0)
    }

    public func push(_ value: Int) {
        _lua_pushinteger(L, value)
    }

    public func push(_ value: UInt) {
        _lua_pushinteger(L, Int(bitPattern: value))
    }

    public func push(_ value: Float) {
        _lua_pushnumber(L, Double(value))
    }

    public func push(_ value: Double) {
        _lua_pushnumber(L, value)
    }

    public func push(_ value: String) {
        _lua_pushstring(L, value)
    }
}

extension Lua {
    public func get(_ type: Bool.Type, at index: Int) -> Bool {
        return _lua_toboolean(L, Int32(index)) == 1
    }

    public func get(_ type: Int.Type, at index: Int) -> Int {
        return _lua_tointeger(L, Int32(index))
    }

    public func get(_ type: UInt.Type, at index: Int) -> UInt {
        return UInt(bitPattern: _lua_tointeger(L, Int32(index)))
    }

    public func get(_ type: Float.Type, at index: Int) -> Float {
        return Float(_lua_tonumber(L, Int32(index)))
    }

    public func get(_ type: Double.Type, at index: Int) -> Double {
        return _lua_tonumber(L, Int32(index))
    }

    public func get(_ type: String.Type, at index: Int) -> String? {
        guard let pointer = _lua_tolstring(L, Int32(index), nil) else {
            return nil
        }
        return String(cString: pointer)
    }
}
