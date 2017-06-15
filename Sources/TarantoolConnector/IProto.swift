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

public struct IProto: DataSource, LuaScript {
    let connection: IProtoConnection

    public init(connection: IProtoConnection) {
        self.connection = connection
    }

    // MARK: DataSource

    public func count(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack]
    ) throws -> Int {
        let result = try connection.eval(
            "return box.space[\(spaceId)].index[\(indexId)]:count()")

        guard let count = Int(result.first) else {
            throw TarantoolError.invalidTuple(
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
    ) throws -> AnySequence<IProtoTuple> {
        let result = try connection.request(code: .select, keys: [
            .spaceId:  .int(spaceId),
            .indexId:  .int(indexId),
            .limit:    .int(limit),
            .offset:   .int(offset),
            .iterator: .int(iterator.rawValue),
            .key:      .array(keys)])

        var tuples: [IProtoTuple] = []
        for row in [MessagePack](result) {
            guard let items = [MessagePack](row) else {
                throw TarantoolError.invalidTuple(
                    message: "expected array, received: \(row)")
            }
            tuples.append(IProtoTuple(rawValue: items))
        }

        // TODO: read and parse from socket lazily

        return AnySequence { tuples.makeIterator() }
    }

    public func get(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws -> IProtoTuple? {
        let result = try connection.request(code: .select, keys: [
            .spaceId:  .int(spaceId),
            .indexId:  .int(indexId),
            .limit:    .int(1),
            .offset:   .int(0),
            .iterator: .int(Iterator.eq.rawValue),
            .key:      .array(keys)])

        guard let tuple = [MessagePack]([MessagePack](result).first) else {
            return nil
        }

        return IProtoTuple(rawValue: tuple)
    }

    public func insert(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        _ = try connection.request(code: .insert, keys: [
            .spaceId: .int(spaceId),
            .tuple:   .array(tuple)])
    }

    public func insertAutoincrement(
        _ spaceId: Int,
        _ tuple: [MessagePack]
    ) throws -> Int {
        let result = try connection.eval("""
            local id, tuple = ...
            return box.space[id]:auto_increment(tuple)
            """, arguments: [.int(spaceId), .array(tuple)])

        guard let tuple = [MessagePack]([MessagePack](result).first),
            let id = Int(tuple[0]) else {
                throw TarantoolError.invalidTuple(
                    message: "expected array, received: \(result)")
        }

        return id
    }

    public func replace(_ spaceId: Int, _ tuple: [MessagePack]) throws {
        _ = try connection.request(code: .replace, keys: [
            .spaceId: .int(spaceId),
            .tuple:   .array(tuple)])
    }

    public func delete(
        _ spaceId: Int, _ indexId: Int, _ keys: [MessagePack]
    ) throws {
        _ = try connection.request(code: .delete, keys: [
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
        _ = try connection.request(code: .update, keys: [
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
        _ = try connection.request(code: .upsert, keys: [
            .spaceId: .int(spaceId),
            .indexId: .int(indexId),
            .tuple:   .array(tuple),
            .ops:     .array(ops)])
    }

    // MARK: LuaScript

    public func call(
        _ function: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try connection.call(function, arguments: arguments)
    }

    public func eval(
        _ expression: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try connection.eval(expression, arguments: arguments)
    }
}
