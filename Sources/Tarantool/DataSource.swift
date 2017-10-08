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

public protocol DataSource {
    associatedtype Row: Tarantool.Tuple

    func count(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack]
    ) throws -> Int

    func select(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [MessagePack],
        _ offset: Int,
        _ limit: Int
    ) throws -> AnySequence<Row>

    func get(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [MessagePack]
    ) throws -> Row?

    func insert(
        _ spaceId: Int,
        _ tuple: [MessagePack]
    ) throws

    func replace(
        _ spaceId: Int,
        _ tuple: [MessagePack]
    ) throws

    func delete(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [MessagePack]
    ) throws

    func update(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [MessagePack],
        _ ops: [MessagePack]
    ) throws

    func upsert(
        _ spaceId: Int,
        _ indexId: Int,
        _ tuple: [MessagePack],
        _ ops: [MessagePack]
    ) throws
}
