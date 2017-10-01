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
}
