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

private let _schema: Int = 272
private let _space: Int = 280
private let _vspace: Int = 281
private let _vindex: Int = 289

private let admin: Int = 1

public struct Schema<T: DataSource & LuaScript> {
    let source: T
    public private(set) var spaces: [String: Space<T>]

    public init(_ source: T) throws {
        self.source = source

        let indicesView =
            Space(id: _vindex, name: "_vindex", indices: [], source: source)

        let indices = try indicesView.select(iterator: .all)
            .reduce(into: [Int : [Index<T>]]()) { (result, row) in
                guard let index =
                    Index(from: row, source: source) else {
                        throw Tarantool.Error.invalidIndex(message: "\(row)")
                }
                result[index.spaceId, default: []].append(index)
            }

        let spacesView =
            Space(id: _vspace, name: "_vspace", indices: [], source: source)

        let spaces = try spacesView.select(iterator: .all)
            .reduce(into: [String : Space<T>]()) { (result, row) in
                guard let id = Int(row[0]),
                    let name = String(row[2]),
                    let rawEngine = String(row[3]),
                    let engine = Space<T>.Engine(rawValue: rawEngine) else {
                        throw Tarantool.Error.invalidSchema
                }
                result[name] = Space(
                    id: id,
                    name: name,
                    engine: engine,
                    indices: indices[id, default: []],
                    source: source)
            }
        self.spaces = spaces
    }

    @discardableResult
    public mutating func createSpace(
        name: String,
        engine: Space<T>.Engine = .memtx
    ) throws -> Space<T> {
        let options: String
        switch engine {
        case .memtx: options = "{ engine='memtx' }"
        case .vinyl: options = "{ engine='vinyl' }"
        case .sysview: throw Tarantool.Error.invalidEngine
        }
        let script = "return box.schema.space.create('\(name)', \(options)).id"
        let result = try source.eval(script, arguments: [])
        guard result.count == 1, let id = Int(result[0]) else {
            let message = "[integer] expected, got \(result)"
            throw Tarantool.Error.invalidTuple(message: message)
        }
        let space = Space(
            id: id,
            name: name,
            engine: engine,
            indices: [],
            source: source)
        spaces[name] = space
        return space
    }
}
