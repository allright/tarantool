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

public typealias Tuple = [MessagePack]
public typealias Map = [MessagePack : MessagePack]

public protocol SchemaProtocol {
    var spaces: [String : Space] { get }
}

public protocol DataSource {
    func count(spaceId: Int, indexId: Int, iterator: Iterator, keys: Tuple) throws -> Int
    func select(spaceId: Int, indexId: Int, iterator: Iterator, keys: Tuple, offset: Int, limit: Int) throws -> [Tuple]
    func get(spaceId: Int, indexId: Int, keys: Tuple) throws -> Tuple?
    func insert(spaceId: Int, tuple: Tuple) throws
    func replace(spaceId: Int, tuple: Tuple) throws
    func delete(spaceId: Int, indexId: Int, keys: Tuple) throws
    func update(spaceId: Int, indexId: Int, keys: Tuple, ops: Tuple) throws
    func upsert(spaceId: Int, indexId: Int, tuple: Tuple, ops: Tuple) throws
}
