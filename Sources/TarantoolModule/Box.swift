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
import Foundation

public struct Box {
    static func count(spaceId: UInt32, indexId: UInt32, iterator: Iterator, keys: [UInt8]) throws -> Int {
        let pKeys = try copyToInternalMemory(keys)
        let count = _box_index_count(spaceId, indexId, Int32(iterator.rawValue), pKeys, pKeys+keys.count)
        guard count >= 0 else {
            throw BoxError()
        }
        return count
    }

    static func select(spaceId: UInt32, indexId: UInt32, iterator: Iterator, keys: [UInt8]) throws -> [Tuple] {
        let pointer = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        guard let iterator = _box_index_iterator(spaceId, indexId, Int32(iterator.rawValue), pointer, pointer+keys.count) else {
            throw BoxError()
        }
        defer { _box_iterator_free(iterator) }

        var rows: [Tuple] = []

        var result: OpaquePointer?
        while true {
            guard _box_iterator_next(iterator, &result) == 0 else {
                throw BoxError()
            }
            guard let tuple = result else {
                break
            }
            rows.append(try unpackTuple(tuple))
        }

        return rows
    }

    static func get(spaceId: UInt32, indexId: UInt32, keys: [UInt8]) throws -> Tuple? {
        var result: OpaquePointer?
        let pKeys = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        guard _box_index_get(spaceId, indexId, pKeys, pKeys+keys.count, &result) == 0 else {
            throw BoxError()
        }
        guard let tuple = result else {
            return nil
        }
        return try unpackTuple(tuple)
    }

    static func insert(spaceId: UInt32, tuple: [UInt8]) throws {
        let pointer = try copyToInternalMemory(tuple)
        guard _box_insert(spaceId, pointer, pointer+tuple.count, nil) == 0 else {
            throw BoxError()
        }
    }

    static func replace(spaceId: UInt32, tuple: [UInt8]) throws {
        let pointer = try copyToInternalMemory(tuple)
        guard _box_replace(spaceId, pointer, pointer+tuple.count, nil) == 0 else {
            throw BoxError()
        }
    }

    static func update(spaceId: UInt32, indexId: UInt32, keys: [UInt8], ops: [UInt8]) throws {
        let pKeys = try copyToInternalMemory(keys)
        let pOps = try copyToInternalMemory(ops)
        guard _box_update(spaceId, indexId, pKeys, pKeys+keys.count, pOps, pOps+ops.count, 0, nil) == 0 else {
            throw BoxError()
        }
    }

    static func upsert(spaceId: UInt32, indexId: UInt32, tuple: [UInt8], ops: [UInt8]) throws {
        let pTuple = try copyToInternalMemory(tuple)
        let pOps = try copyToInternalMemory(ops)
        guard _box_upsert(spaceId, indexId, pTuple, pTuple+tuple.count, pOps, pOps+ops.count, 0, nil) == 0 else {
            throw BoxError()
        }
    }

    static func delete(spaceId: UInt32, indexId: UInt32, keys: [UInt8]) throws{
        let pointer = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        guard _box_delete(spaceId, indexId, pointer, pointer+keys.count, nil) == 0 else {
            throw BoxError()
        }
    }
}
