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

public struct Schema<T: DataSource & LuaScript> {
    let source: T
    public private(set) var spaces: [String: Space<T>]

    public init(_ source: T) throws {
        self.source = source

        let sysview = Space(id: _vspace, name: "_vspace", source: source)
        let tuples = try sysview.select(.all)

        var spaces: [String: Space<T>] = [:]
        for tuple in tuples {
            guard let id = Int(tuple[0]),
                let name = String(tuple[2]) else {
                    throw TarantoolError.invalidSchema
            }
            spaces[name] = Space(id: id, name: name, source: source)
        }
        self.spaces = spaces
    }

    public mutating func createSpace(name: String) throws {
        let script = "return box.schema.space.create('\(name)').id"
        let result = try source.eval(script, arguments: [])
        guard result.count == 1, let id = Int(result[0]) else {
            let message = "[integer] expected, got \(result)"
            throw TarantoolError.invalidTuple(message: message)
        }
        spaces[name] = Space(id: id, name: name, source: source)
    }

    @discardableResult
    public mutating func createIndex(
        name: String,
        type: IndexType = .tree,
        parts: [Int: IndexFieldType]? = nil,
        in space: String
    ) throws -> Index {
        let partsString: String
        if let parts = parts {
            let string = parts
                .map({ "\($0.key), '\($0.value.rawValue)'" })
                .joined(separator: ", ")
            partsString = ", parts = {\(string)}"
        } else {
            partsString = ""
        }

        let script =
            "return box.space.\(space):create_index(" +
                "'\(name)', {type = '\(type.rawValue)'\(partsString)}" +
        ")"
        let result = try source.eval(script, arguments: [])
        guard result.count == 1,
            let table = Map(result[0]),
            let id = Int(table["id"]) else {
                let message = "[map] expected, got \(result)"
                throw TarantoolError.invalidTuple(message: message)
        }
        let unique = Bool(table["unique"]) ?? false
        return Index(id: id, name: name, type: type, unique: unique)
    }
}
