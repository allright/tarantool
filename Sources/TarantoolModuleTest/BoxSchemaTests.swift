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
        let schema = try Schema(BoxDataSource())
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
            guard spaces[key]?.id == value else {
                throw "spaces['\(key)']?.id is not equal to \(value)"
            }
        }
    }

    static func testCreateSpace() throws {
        var schema = try Schema(BoxDataSource())

        try schema.createSpace(name: "new_space")
        guard let newSpace = schema.spaces["new_space"] else {
            throw "new_space not found"
        }
        guard newSpace.id == 512 else {
            throw "new_space.id \(newSpace.id) is not equal to 512"
        }

        try schema.createSpace(name: "another_space")
        guard let anotherSpace = schema.spaces["another_space"] else {
            throw "another_space not found"
        }
        guard anotherSpace.id == 513 else {
            throw "another_space.id \(anotherSpace.id) is not equal to 513"
        }
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
