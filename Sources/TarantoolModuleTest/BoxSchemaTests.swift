/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Platform
import Foundation
import MessagePack
import TarantoolModule

struct BoxSchemaTests {
    static func testSchema() throws {
        let schema = try Schema(Box())
        guard schema.spaces.count > 0 else {
            throw "schema.spaces.count == 0"
        }
        let spaces = schema.spaces
        let expexted = [
            "_schema": 272,
            "_space": 280,
            "_vspace": 281,
            "_index": 288,
            "_vindex": 289,
            "_func": 296,
            "_vfunc": 297,
            "_user": 304,
            "_vuser": 305,
            "_priv": 312,
            "_vpriv": 313,
            "_cluster": 320,
        ]
        for (key, value) in expexted {
            try assertEqualThrows(spaces[key]?.id, value)
        }
    }

    static func testCreateSpace() throws {
        var schema = try Schema(Box())

        try schema.createSpace(name: "new_space")
        guard let newSpace = schema.spaces["new_space"] else {
            throw "new_space not found"
        }
        try assertEqualThrows(newSpace.id, 512)
        try assertEqualThrows(newSpace.name, "new_space")

        try schema.createSpace(name: "another_space")
        guard let anotherSpace = schema.spaces["another_space"] else {
            throw "another_space not found"
        }
        try assertEqualThrows(anotherSpace.id, 513)
        try assertEqualThrows(anotherSpace.name, "another_space")
    }

    static func testCreateIndex() throws {
        var schema = try Schema(Box())
        try schema.createSpace(name: "new_space")

        let tree = try schema.createIndex(name: "tree", in: "new_space")
        let expected0 =
            Index(id: 0, name: "tree", type: .tree, unique: true)
        try assertEqualThrows(tree, expected0)

        let rtree = try schema.createIndex(
            name: "rtree", type: .rtree, in: "new_space")
        let expected1 =
            Index(id: 1, name: "rtree", type: .rtree, unique: false)
        try assertEqualThrows(rtree, expected1)

        let nonUnique = try schema.createIndex(
            name: "non_unique", unique: false, in: "new_space")
        let expected2 =
            Index(id: 2, name: "non_unique", type: .tree, unique: false)
        try assertEqualThrows(nonUnique, expected2)
    }
}

// C API Wrappers

@_silgen_name("BoxSchemaTests_testSchema")
public func BoxSchemaTests_testSchema(context: BoxContext) -> BoxResult {
    do {
        try BoxSchemaTests.testSchema()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}

@_silgen_name("BoxSchemaTests_testCreateSpace")
public func BoxSchemaTests_testCreateSpace(context: BoxContext) -> BoxResult {
    do {
        try BoxSchemaTests.testCreateSpace()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}

@_silgen_name("BoxSchemaTests_testCreateIndex")
public func BoxSchemaTests_testCreateIndex(context: BoxContext) -> BoxResult {
    do {
        try BoxSchemaTests.testCreateIndex()
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
    return 0
}
