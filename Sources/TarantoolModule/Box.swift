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

@_exported import Tarantool

public struct Box: DataSource, LuaScript {
    public init() {}

    // MARK: DataSource

    public func count(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [IndexKey]
    ) throws -> Int {
        let keys = try keys.encode()
        return try Box.API.count(
            UInt32(spaceId), UInt32(indexId), iterator, keys)
    }

    public func select(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [IndexKey],
        _ offset: Int,
        _ limit: Int
    ) throws -> AnySequence<Tuple> {
        let keys = try keys.encode()
        return try Box.API.select(
            numericCast(spaceId), numericCast(indexId), iterator, keys)
    }

    public func get(
        _ spaceId: Int, _ indexId: Int, _ keys: [IndexKey]
    ) throws -> Tuple? {
        let keys = try keys.encode()
        return try Box.API.get(UInt32(spaceId), UInt32(indexId), keys)
    }

    @discardableResult
    public func insert(
        _ spaceId: Int,
        _ tuple: [MessagePack]
    ) throws -> MessagePack {
        let tuple = try MessagePack.encode(.array(tuple))
        let result = try Box.API.insert(UInt32(spaceId), tuple)
        guard let index = result[0] else {
            throw Error.init(code: .invalidMsgpack, message: "Box.insert")
        }
        return index
    }

    public func replace(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        let tuple = try MessagePack.encode(.array(tuple))
        try Box.API.replace(UInt32(spaceId), tuple)
    }

    public func delete(
        _ spaceId: Int, _ indexId: Int, _ keys: [IndexKey]
    ) throws {
        let keys = try keys.encode()
        try Box.API.delete(UInt32(spaceId), UInt32(indexId), keys)
    }

    public func update(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [IndexKey],
        _ ops: [MessagePack]
    ) throws {
        let keys = try keys.encode()
        let ops = try MessagePack.encode(.array(ops))
        try Box.API.update(UInt32(spaceId), UInt32(indexId), keys, ops)
    }

    public func upsert(
        _ spaceId: Int,
        _ indexId: Int,
        _ tuple: [MessagePack],
        _ ops: [MessagePack]
    ) throws {
        let tuple = try MessagePack.encode(.array(tuple))
        let ops = try MessagePack.encode(.array(ops))
        try Box.API.upsert(UInt32(spaceId), UInt32(indexId), tuple, ops)
    }

    // MARK: LuaScript

    public func call(
        _ function: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try Lua.call(function, arguments)
    }

    public func eval(
        _ expression: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try Lua.eval(expression, arguments)
    }
}
