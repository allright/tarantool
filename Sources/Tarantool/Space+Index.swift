/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

extension Space {
    @discardableResult
    public mutating func createIndex(
        name: String,
        type: IndexType = .tree,
        sequence: Bool? = nil,
        unique: Bool? = nil,
        parts: [Int: IndexFieldType]? = nil
    ) throws -> Index<T> {
        let arguments = buildArguments(
            type: type, sequence: sequence, unique: unique, parts: parts)

        let script = "return " +
            "box.space.\(self.name):create_index('\(name)', {\(arguments)})"

        let result = try source.eval(script, arguments: [])
        guard result.count == 1,
            let table = Map(result[0]),
            let id = Int(table["id"]) else {
                let message = "[map] expected, got \(result)"
                throw TarantoolError.invalidTuple(message: message)
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
            source: source)
    }

    private func buildArguments(
        type: IndexType,
        sequence: Bool?,
        unique: Bool?,
        parts: [Int: IndexFieldType]?
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
            let string = parts.map({ "\($0.key), '\($0.value.rawValue)'" })
                .joined(separator: ", ")
            arguments.append("parts = {\(string)}")
        }

        return arguments.joined(separator: ", ")
    }
}
