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

    @discardableResult
    public mutating func createSpace(name: String) throws -> Space<T> {
        let script = "return box.schema.space.create('\(name)').id"
        let result = try source.eval(script, arguments: [])
        guard result.count == 1, let id = Int(result[0]) else {
            let message = "[integer] expected, got \(result)"
            throw TarantoolError.invalidTuple(message: message)
        }
        let space = Space(id: id, name: name, source: source)
        spaces[name] = space
        return space
    }

    @discardableResult
    public mutating func createIndex(
        name: String,
        type: IndexType = .tree,
        unique: Bool? = nil,
        parts: [Int: IndexFieldType]? = nil,
        in space: String
    ) throws -> Index {
        let arguments = buildArguments(type: type, unique: unique, parts: parts)

        let script =
            "return box.space.\(space):create_index('\(name)', {\(arguments)})"
        
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

    private func buildArguments(
        type: IndexType,
        unique: Bool?,
        parts: [Int: IndexFieldType]?
    ) -> String {
        var arguments = [String]()

        arguments.append("type = '\(type.rawValue)'")

        if let unique = unique {
            arguments.append("unique = \(unique)")
        }

        if let parts = parts {
            let string = parts.map({ "\($0.key), '\($0.value.rawValue)'" })
                .joined(separator: ", ")
            arguments.append("parts = {\(string)}")
        }

        return arguments.joined(separator: ", ")
    }
}
