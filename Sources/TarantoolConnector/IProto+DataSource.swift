/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Foundation
import MessagePack
import Tarantool

extension IProto: DataSource {
    public func count(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack]
    ) throws -> Int {
        let result = try eval(
            "return box.space[\(spaceId)].index[\(indexId)]:count()")

        guard let count = Int(result.first) else {
            throw Tarantool.Error.invalidTuple(
                message: "expected integer, received: \(result)")
        }

        return count
    }

    public func select(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack],
        _ offset: Int,
        _ limit: Int
    ) throws -> AnySequence<Tuple> {
        let result = try request(code: .select, keys: [
            .spaceId:  .int(spaceId),
            .indexId:  .int(indexId),
            .limit:    .int(limit),
            .offset:   .int(offset),
            .iterator: .int(iterator.rawValue),
            .key:      .array(keys)])

        return AnySequence { TupleIterator(tuples: result) }
    }

    public func get(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws -> Tuple? {
        let result = try request(code: .select, keys: [
            .spaceId:  .int(spaceId),
            .indexId:  .int(indexId),
            .limit:    .int(1),
            .offset:   .int(0),
            .iterator: .int(Iterator.eq.rawValue),
            .key:      .array(keys)])

        guard let tuple = [MessagePack]([MessagePack](result).first) else {
            return nil
        }

        return Tuple(tuple)
    }

    public func insert(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        _ = try request(code: .insert, keys: [
            .spaceId: .int(spaceId),
            .tuple:   .array(tuple)])
    }


    public func replace(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        _ = try request(code: .replace, keys: [
            .spaceId: .int(spaceId),
            .tuple:   .array(tuple)])
    }

    public func delete(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws {
        _ = try request(code: .delete, keys: [
            .spaceId: .int(spaceId),
            .indexId: .int(indexId),
            .key:     .array(keys)])
    }

    public func update(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [MessagePack],
        _ ops: [MessagePack]
    ) throws {
        _ = try request(code: .update, keys: [
            .spaceId: .int(spaceId),
            .indexId: .int(indexId),
            .key:     .array(keys),
            .tuple:   .array(ops)])
    }

    public func upsert(
        _ spaceId: Int,
        _ indexId: Int,
        _ tuple: [MessagePack],
        _ ops: [MessagePack]
    ) throws {
        _ = try request(code: .upsert, keys: [
            .spaceId: .int(spaceId),
            .indexId: .int(indexId),
            .tuple:   .array(tuple),
            .ops:     .array(ops)])
    }
}
