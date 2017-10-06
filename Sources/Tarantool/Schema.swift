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
fileprivate let _vindex: Int = 289

fileprivate let admin: Int = 1

public struct Schema<T: DataSource & LuaScript> {
    let source: T
    public private(set) var spaces: [String: Space<T>]

    public init(_ source: T) throws {
        self.source = source

        let indicesView =
            Space(id: _vindex, name: "_vindex", indices: [], source: source)

        let indices = try indicesView.select(.all)
            .reduce(into: [Int : [Index<T>]]()) { (result, row) in
                guard let index =
                    Index(from: row.rawValue, source: source) else {
                        throw TarantoolError.invalidIndex
                }
                result[index.spaceId, default: []].append(index)
            }

        let spacesView =
            Space(id: _vspace, name: "_vspace", indices: [], source: source)

        let spaces = try spacesView.select(.all)
            .reduce(into: [String : Space<T>]()) { (result, row) in
                guard let id = Int(row[0]),
                    let name = String(row[2]) else {
                        throw TarantoolError.invalidSchema
                }
                result[name] = Space(
                    id: id,
                    name: name,
                    indices: indices[id, default: []],
                    source: source)
            }
        self.spaces = spaces
    }

    @discardableResult
    public mutating func createSpace(name: String) throws -> Space<T> {
        let script = "return box.schema.space.create('\(name)').id"
        let result = try source.eval(script, arguments: [])
        guard result.count == 1, let id = Int(result[0]) else {
            let message = "[integer] expected, got \(result)"
            throw TarantoolError.invalidTuple(message: message)
        }
        let space = Space(id: id, name: name, indices: [], source: source)
        spaces[name] = space
        return space
    }
}

extension Index {
    init?(from messagePack: [MessagePack], source: T) {
        guard messagePack.count >= 5,
            let spaceId = Int(messagePack[0]),
            let id = Int(messagePack[1]),
            let name = String(messagePack[2]),
            let typeString = String(messagePack[3]),
            let type = IndexType(rawValue: typeString),
            let options = [MessagePack : MessagePack](messagePack[4]),
            let unique = Bool(options["unique"]) else {
                return nil
        }
        self = Index(
            spaceId: spaceId,
            id: id,
            name: name,
            type: type,
            unique: unique,
            source: source)
    }
}
