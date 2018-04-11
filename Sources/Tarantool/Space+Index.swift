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

extension Space {
    typealias Error = Tarantool.Error

    @discardableResult
    public mutating func createIndex(
        name: String,
        type: Index<T>.`Type` = .tree,
        sequence: Bool? = nil,
        unique: Bool? = nil,
        parts: [Index<T>.Part]? = nil
    ) throws -> Index<T> {
        let arguments = buildArguments(
            type: type, sequence: sequence, unique: unique, parts: parts)

        let script = "return " +
            "box.space.\(self.name):create_index('\(name)', {\(arguments)})"

        let result = try source.eval(script, arguments: [])
        guard result.count == 1, let table = result[0].dictionaryValue else {
            throw Error.invalidTuple(message: "[index] \(result)")
        }
        guard let id = table["id"]?.integerValue else {
            throw Error.invalidIndex(message: "invalid 'id' in \(table)")
        }
        guard let partsArray = table["parts"]?.arrayValue else {
            throw Error.invalidIndex(message: "invalid 'parts' in \(table)")
        }
        guard let parts = [Index<T>.Part](from: partsArray) else {
            throw Error.invalidIndex(message: "indalid 'parts' \(partsArray)")
        }

        let unique = Bool(table["unique"]) ?? false
        let sequenceId = Int(table["sequence_id"])

        return Index(
            spaceId: self.id,
            id: id,
            name: name,
            type: type,
            sequenceId: sequenceId,
            unique: unique,
            parts: parts,
            source: source)
    }

    private func buildArguments(
        type: Index<T>.`Type`,
        sequence: Bool?,
        unique: Bool?,
        parts: [Index<T>.Part]?
    ) -> String {
        var arguments = [String]()

        arguments.append("type = '\(type.rawValue)'")

        if let sequence = sequence {
            arguments.append("sequence = \(sequence)")
        }

        if let unique = unique {
            arguments.append("unique = \(unique)")
        }

        if let parts = parts {
            let string = parts.map({ "\($0.field), '\($0.type.rawValue)'" })
                .joined(separator: ", ")
            arguments.append("parts = {\(string)}")
        }

        return arguments.joined(separator: ", ")
    }
}
