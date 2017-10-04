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

@_exported import Tarantool

public struct Box: DataSource, LuaScript {
    public init() {}

    // MARK: DataSource

    public func count(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack]
    ) throws -> Int {
        let keys = try MessagePack.encode(.array(keys))
        return try BoxWrapper.count(
            UInt32(spaceId), UInt32(indexId), iterator, keys)
    }

    public func select(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack],
        _ offset: Int,
        _ limit: Int
    ) throws -> AnySequence<BoxTuple> {
        let keys = try MessagePack.encode(.array(keys))
        return try BoxWrapper.select(
            numericCast(spaceId), numericCast(indexId), iterator, keys)
    }

    public func get(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws -> BoxTuple? {
        let keys = try MessagePack.encode(.array(keys))
        return try BoxWrapper.get(UInt32(spaceId), UInt32(indexId), keys)
    }

    public func insert(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        let tuple = try MessagePack.encode(.array(tuple))
        try BoxWrapper.insert(UInt32(spaceId), tuple)
    }

    public func insertAutoincrement(
        _ spaceId: Int,
        _ tuple: [MessagePack]
    ) throws -> Int {
        var id = 0
        let emptyKeys = try MessagePack.encode(.array([]))
        if let max = try BoxWrapper.max(UInt32(spaceId), UInt32(0), emptyKeys) {
            id = max + 1
        }
        var tuple = tuple
        tuple.insert(.int(id), at: 0)
        let tupleBytes = try MessagePack.encode(.array(tuple))
        try BoxWrapper.insert(UInt32(spaceId), tupleBytes)
        return id
    }

    public func replace(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        let tuple = try MessagePack.encode(.array(tuple))
        try BoxWrapper.replace(UInt32(spaceId), tuple)
    }

    public func delete(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws {
        let keys = try MessagePack.encode(.array(keys))
        try BoxWrapper.delete(UInt32(spaceId), UInt32(indexId), keys)
    }

    public func update(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [MessagePack],
        _ ops: [MessagePack]
    ) throws {
        let keys = try MessagePack.encode(.array(keys))
        let ops = try MessagePack.encode(.array(ops))
        try BoxWrapper.update(UInt32(spaceId), UInt32(indexId), keys, ops)
    }

    public func upsert(
        _ spaceId: Int,
        _ indexId: Int,
        _ tuple: [MessagePack],
        _ ops: [MessagePack]
    ) throws {
        let tuple = try MessagePack.encode(.array(tuple))
        let ops = try MessagePack.encode(.array(ops))
        try BoxWrapper.upsert(UInt32(spaceId), UInt32(indexId), tuple, ops)
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
