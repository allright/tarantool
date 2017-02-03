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
import Tarantool

public struct IProtoDataSource: DataSource {
    let connection: IProtoConnection

    public init(connection: IProtoConnection) {
        self.connection = connection
    }

    public func count(spaceId: Int, indexId: Int = 0, iterator: Iterator, keys: Tuple = []) throws -> Int {
        let result = try connection.eval("return box.space[\(spaceId)].index[\(indexId)]:count()")
        guard let first = result.first, let count = Int(first) else {
            throw TarantoolError.invalidTuple(message: "expected integer, received: \(result)")
        }
        return count
    }

    public func select(spaceId: Int, indexId: Int = 0, iterator: Iterator, keys: Tuple = [], offset: Int = 0, limit: Int = 1000) throws -> [Tuple] {
        let result = try connection.request(code: .select, keys: [
            .spaceId:  .int(spaceId),
            .indexId:  .int(indexId),
            .limit:    .int(limit),
            .offset:   .int(offset),
            .iterator: .int(iterator.rawValue),
            .key:      .array(keys)]
        )

        var rows: [Tuple] = []
        for tuple in Tuple(result) {
            guard let row = Tuple(tuple) else {
                throw TarantoolError.invalidTuple(message: "expected array, received: \(tuple)")
            }
            rows.append(row)
        }
        return rows
    }

    public func get(spaceId: Int, indexId: Int = 0, keys: Tuple) throws -> Tuple? {
        let result = try connection.request(code: .select, keys: [
            .spaceId:  .int(spaceId),
            .indexId:  .int(indexId),
            .limit:    .int(1),
            .offset:   .int(0),
            .iterator: .int(Iterator.eq.rawValue),
            .key:      .array(keys)]
        )

        return Tuple(Tuple(result).first)
    }

    public func insert(spaceId: Int, tuple: Tuple) throws {
        _ = try connection.request(code: .insert, keys: [
            .spaceId: .int(spaceId),
            .tuple:   .array(tuple)]
        )
    }

    public func replace(spaceId: Int, tuple: Tuple) throws {
        _ = try connection.request(code: .replace, keys: [
            .spaceId: .int(spaceId),
            .tuple:   .array(tuple)]
        )
    }

    public func delete(spaceId: Int, indexId: Int = 0, keys: Tuple) throws {
        _ = try connection.request(code: .delete, keys: [
            .spaceId: .int(spaceId),
            .indexId: .int(indexId),
            .key:     .array(keys)]
        )
    }

    public func update(spaceId: Int, indexId: Int = 0, keys: Tuple, ops: Tuple) throws {
        _ = try connection.request(code: .update, keys: [
            .spaceId: .int(spaceId),
            .indexId: .int(indexId),
            .key:     .array(keys),
            .tuple:   .array(ops)]
        )
    }

    public func upsert(spaceId: Int, indexId: Int = 0, tuple: Tuple, ops: Tuple) throws {
        _ = try connection.request(code: .upsert, keys: [
            .spaceId: .int(spaceId),
            .indexId: .int(indexId),
            .tuple:   .array(tuple),
            .ops:     .array(ops)]
        )
    }
}
