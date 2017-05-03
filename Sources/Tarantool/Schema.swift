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

fileprivate let _schema: Int = 272
fileprivate let _space: Int = 280
fileprivate let _vspace: Int = 281

fileprivate let admin: Int = 1

public struct Schema<T: DataSource> {
    let source: T
    public private(set) var spaces: [String: Space<T>]

    public init(_ source: T) throws {
        self.source = source
        self.spaces = [:]
        try update()
    }

    mutating func update() throws {
        let sysview = Space(id: _vspace, source: source)
        let tuples = try sysview.select(.all)

        var spaces: [String: Space<T>] = [:]
        for tuple in tuples {
            guard let id = Int(tuple[0]),
                let name = String(tuple[2]) else {
                    throw TarantoolError.invalidSchema
            }
            spaces[name] = Space(id: id, source: source)
        }
        self.spaces = spaces
    }

    public mutating func createSpace(name: String) throws {
        let schemaSpace = Space(id: _schema, source: source)
        try schemaSpace.upsert(["max_id", 512], operations: [["+", 1, 1]])
        guard let result = try schemaSpace.get(["max_id"]) else {
            throw TarantoolError.unexpected(message: "can't read max_id")
        }
        guard result.count == 2, let maxId = Int(result[1]) else {
            throw TarantoolError.unexpected(message: "invalid max_id tuple")
        }

        let spaceSpace = Space(id: _space, source: source)
        let id = maxId
        let userId = admin
        let engine = "memtx"
        let fieldCount = 0
        let options: Map = [:]
        let format: [MessagePack] = []

        try spaceSpace.insert([
            .int(id),
            .int(userId),
            .string(name),
            .string(engine),
            .int(fieldCount),
            .map(options),
            .array(format)
        ])

        try update()
    }
}
