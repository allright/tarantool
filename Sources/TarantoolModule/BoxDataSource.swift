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

public struct BoxDataSource: DataSource {
    public init() {}

    public func count(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack]
    ) throws -> Int {
        let keys = MessagePack.encode(.array(keys))
        return try Box.count(UInt32(spaceId), UInt32(indexId), iterator, keys)
    }

    public func select(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack],
        _ offset: Int,
        _ limit: Int
    ) throws -> AnySequence<BoxTuple> {
        let keys = MessagePack.encode(.array(keys))
        return try Box.select(
            numericCast(spaceId), numericCast(indexId), iterator, keys)
    }

    public func get(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws -> BoxTuple? {
        let keys = MessagePack.encode(.array(keys))
        return try Box.get(UInt32(spaceId), UInt32(indexId), keys)
    }

    public func insert(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        let tuple = MessagePack.encode(.array(tuple))
        try Box.insert(UInt32(spaceId), tuple)
    }

    public func replace(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        let tuple = MessagePack.encode(.array(tuple))
        try Box.replace(UInt32(spaceId), tuple)
    }

    public func delete(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws {
        let keys = MessagePack.encode(.array(keys))
        try Box.delete(UInt32(spaceId), UInt32(indexId), keys)
    }

    public func update(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [MessagePack],
        _ ops: [MessagePack]
    ) throws {
        let keys = MessagePack.encode(.array(keys))
        let ops = MessagePack.encode(.array(ops))
        try Box.update(UInt32(spaceId), UInt32(indexId), keys, ops)
    }

    public func upsert(
        _ spaceId: Int,
        _ indexId: Int,
        _ tuple: [MessagePack],
        _ ops: [MessagePack]
    ) throws {
        let tuple = MessagePack.encode(.array(tuple))
        let ops = MessagePack.encode(.array(ops))
        try Box.upsert(UInt32(spaceId), UInt32(indexId), tuple, ops)
    }
}
