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

struct BoxWrapper {
    static func count(
        _ spaceId: UInt32,
        _ indexId: UInt32,
        _ iterator: Iterator,
        _ keys: [UInt8]
    ) throws -> Int {
        let pKeys = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        let pKeysEnd = pKeys + keys.count
        let count = _box_index_count(
            spaceId, indexId, Int32(iterator.rawValue), pKeys, pKeysEnd)
        guard count >= 0 else {
            throw BoxError()
        }
        return count
    }

    static func select(
        _ spaceId: UInt32,
        _ indexId: UInt32,
        _ iterator: Iterator,
        _ keys: [UInt8]
    ) throws -> AnySequence<BoxTuple> {
        let pKeys = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        let pKeysEnd = pKeys + keys.count
        guard let iterator = _box_index_iterator(
            spaceId, indexId, Int32(iterator.rawValue), pKeys, pKeysEnd) else {
                throw BoxError()
        }
        return AnySequence { BoxIterator(iterator) }
    }

    static func get(
        _ spaceId: UInt32, _ indexId: UInt32, _ keys: [UInt8]
    ) throws -> BoxTuple? {
        var result: OpaquePointer?
        let pKeys = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        guard _box_index_get(
            spaceId, indexId, pKeys, pKeys+keys.count, &result) == 0 else {
                throw BoxError()
        }
        guard let tuple = result else {
            return nil
        }
        return BoxTuple(tuple)
    }

    static func insert(_ spaceId: UInt32, _ tuple: [UInt8]) throws {
        let pointer = try copyToInternalMemory(tuple)
        guard _box_insert(
            spaceId, pointer, pointer+tuple.count, nil) == 0 else {
                throw BoxError()
        }
    }

    static func max(
        _ spaceId: UInt32, _ indexId: UInt32, _ keys: [UInt8]
    ) throws -> Int? {
        var result: OpaquePointer?
        let pKeys = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        let pKeysEnd = pKeys + keys.count
        guard _box_index_max(
            spaceId, indexId, pKeys, pKeysEnd, &result) == 0 else {
                throw BoxError()
        }
        guard let pointer = result,
            let tuple = BoxTuple(pointer) else {
                return nil
        }
        return tuple[0, as: Int.self]
    }

    static func replace(_ spaceId: UInt32, _ tuple: [UInt8]) throws {
        let pointer = try copyToInternalMemory(tuple)
        guard _box_replace(
            spaceId, pointer, pointer+tuple.count, nil) == 0 else {
                throw BoxError()
        }
    }

    static func update(
        _ spaceId: UInt32,
        _ indexId: UInt32,
        _ keys: [UInt8],
        _ ops: [UInt8]
    ) throws {
        let pKeys = try copyToInternalMemory(keys)
        let pOps = try copyToInternalMemory(ops)
        guard _box_update(
            spaceId,
            indexId,
            pKeys,
            pKeys+keys.count,
            pOps,
            pOps+ops.count,
            0,
            nil) == 0 else {
                throw BoxError()
        }
    }

    static func upsert(
        _ spaceId: UInt32,
        _ indexId: UInt32,
        _ tuple: [UInt8],
        _ ops: [UInt8]
    ) throws {
        let pTuple = try copyToInternalMemory(tuple)
        let pOps = try copyToInternalMemory(ops)
        guard _box_upsert(
            spaceId,
            indexId,
            pTuple,
            pTuple+tuple.count,
            pOps,
            pOps+ops.count,
            0,
            nil) == 0 else {
                throw BoxError()
        }
    }

    static func delete(
        _ spaceId: UInt32, _ indexId: UInt32, _ keys: [UInt8]
    ) throws{
        let pointer = UnsafeRawPointer(keys).assumingMemoryBound(to: CChar.self)
        guard _box_delete(
            spaceId, indexId, pointer, pointer+keys.count, nil) == 0 else {
                throw BoxError()
        }
    }
}
