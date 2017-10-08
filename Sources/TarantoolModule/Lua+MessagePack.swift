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

enum TableType: String {
    case array = "seq"
    case map = "map"
}

let serializeMetaField = "__serialize"

func metatableRef(forTypeHint type: TableType) -> Int {
    do {
        return try Lua.withNewStack { lua in
            lua.createTable(hashElementsCount: 1)
            lua.push(type.rawValue)
            lua.setField(toTableAt: -2, name: serializeMetaField)
            /* automatically reset hints on table change */
            try lua.load(string: "setmetatable((...), nil); return rawset(...)")
            lua.setField(toTableAt: -2, name: "__newindex")
            return lua.ref(at: .registry)
        }
    } catch {
        return Int(LUA_REFNIL)
    }
}

var mapMetatableRef: Int = {
    metatableRef(forTypeHint: .map)
}()

var arrayMetatableRef: Int = {
    metatableRef(forTypeHint: .array)
}()

extension Lua {
    func calculateIndex(_ index: Int) -> Int {
        guard index >= 0 else {
            return top + index + 1
        }
        return index
    }

    func setTypeHint(forTableAt index: Int, type: TableType) {
        let index = calculateIndex(index)
        assert(self.type(at: index) == LUA_TTABLE)
        switch type {
        case .array: rawGet(from: .registry, at: arrayMetatableRef)
        case .map: rawGet(from: .registry, at: mapMetatableRef)
        }
        setMetatable(forTableAt: index)
    }

    func getTypeHint(forTableAt index: Int) throws -> TableType? {
        guard getMetadataField(at: index, name: serializeMetaField) != 0 else {
            return nil
        }
        defer { pop(count: 1) }
        guard type(at: -1) == LUA_TSTRING else {
            return nil
        }
        let hint = get(String.self, at: -1)
        guard let tableType = TableType(rawValue: hint) else {
            return nil
        }
        return tableType
    }
}

extension Lua {
    public static func call(
        _ function: String,
        _ arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try withNewStack { lua in
            lua.getField(from: .globals, name: function)
            lua.checkStack(size: arguments.count, error: "out of stack")
            try lua.push(values: arguments)
            try lua.call(argumentsCount: arguments.count)
            return try lua.popValues()
        }
    }

    public static func eval(
        _ expression: String,
        _ arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try withNewStack { lua in
            try lua.load(string: expression, name: "=eval")
            lua.checkStack(size: arguments.count, error: "out of stack")
            try lua.push(values: arguments)
            try lua.call(argumentsCount: arguments.count)
            return try lua.popValues()
        }
    }
}

extension Lua {
    public func push(values: [MessagePack]) throws {
        for value in values {
            try push(value)
        }
    }

    public func push(_ value: MessagePack) throws {
        switch value {
        case .nil: pushNil()
        case .bool(let value): push(value)
        case .int(let value): push(value)
        case .uint(let value): push(value)
        case .float(let value): push(value)
        case .double(let value): push(value)
        case .string(let value): push(value)
        case .array(let array): try push(array: array)
        case .map(let map): try push(map: map)
        default: throw LuaError(
            message: "argument type \(value) is not supported")
        }
    }

    private func push(array: [MessagePack]) throws {
        let count = array.count
        createTable(arrayElementsCount: count)
        guard count > 0 else {
            return
        }
        for i in 0..<count {
            try push(array[Int(i)])
            rawSet(toTableAt: -2, at: i + 1)
        }
        setTypeHint(forTableAt: -1, type: .array)
    }

    private func push(map: [MessagePack : MessagePack]) throws {
        createTable(hashElementsCount: map.count)
        for (key, value) in map {
            try push(key)
            try push(value)
            rawSet(toTableAt: -3)
        }
        setTypeHint(forTableAt: -1, type: .map)
    }


    public func popValues() throws -> [MessagePack] {
        guard top > 0 else {
            return []
        }
        var result = [MessagePack]()
        for i in 1...top {
            result.append(try get(MessagePack.self, at: i))
        }
        top = 0
        return result
    }

    private func get(
        _ type: MessagePack.Type,
        at index: Int
    ) throws -> MessagePack {
        func getNumber(at index: Int) -> MessagePack {
            let double = get(Double.self, at: index)
            guard double.truncatingRemainder(dividingBy: 1) != 0 else {
                return .int(get(Int.self, at: index))
            }
            return .double(double)
        }

        func getTable(at index: Int) throws -> MessagePack {
            guard let type = try getTypeHint(forTableAt: index) else {
                return try getMap(at: index)
            }
            switch type {
            case .array: return try getArray(at: index)
            case .map: return try getMap(at: index)
            }
        }

        func getArray(at index: Int) throws -> MessagePack {
            var array = [MessagePack]()
            pushNil() // first key
            while next(at: index) {
                let value = try get(MessagePack.self, at: index + 2)
                pop(count: 1)
                guard self.type(at: index + 1) == LUA_TNUMBER else {
                    throw LuaError(message: "invalid array index type")
                }
                let key = get(Int.self, at: index + 1)
                guard key - 1 == array.count else {
                    throw LuaError(message: "invalid array index sequence")
                }
                array.append(value)
            }
            return .array(array)
        }

        func getMap(at index: Int) throws -> MessagePack {
            var map = [MessagePack : MessagePack]()
            pushNil() // first key
            while next(at: index) {
                let value = try get(MessagePack.self, at: index + 2)
                pop(count: 1)
                let key = try get(MessagePack.self, at: index + 1)
                // the next(at: index) will pop the key
                map[key] = value
            }
            return .map(map)
        }

        switch self.type(at: index) {
        case LUA_TNIL: return .nil
        case LUA_TNUMBER: return getNumber(at: index)
        case LUA_TBOOLEAN: return .bool(get(Bool.self, at: index))
        case LUA_TSTRING: return .string(get(String.self, at: index))
        case LUA_TTABLE: return try getTable(at: index)
        default: throw LuaError(message: "return type \(type) is not supported")
        }
    }

    public func popFirst() throws -> MessagePack? {
        guard top > 0 else {
            return nil
        }
        let result = try get(MessagePack.self, at: 1)
        remove(at: 1)
        return result
    }

    public func popLast() throws -> MessagePack? {
        guard top > 0 else {
            return nil
        }
        let result = try get(MessagePack.self, at: top)
        pop(count: 1)
        return result
    }
}
