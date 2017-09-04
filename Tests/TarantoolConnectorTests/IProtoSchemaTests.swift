/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Test
import Foundation
@testable import TestUtils
@testable import TarantoolConnector

class IProtoSchemaTests: TestCase {
    var tarantool: TarantoolProcess!
    var connection: IProtoConnection!

    override func setUp() {
        do {
            if async == nil {
                TestAsync().registerGlobal()
            }
            tarantool = try TarantoolProcess(with: """
                box.schema.user.grant('guest', 'read,write,execute', 'universe')
                box.schema.user.passwd('admin', 'admin')
                """)
            try tarantool.launch()

            connection = try IProtoConnection(host: "127.0.0.1", port: tarantool.port)
        } catch {
            fail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testSchema() {
        do {
            let schema = try Schema(IProto(connection: connection))

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
                assertEqual(spaces[key]?.id, value)
            }
        } catch {
            fail(String(describing: error))
        }
    }

    func testCreateSpace() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))

            try schema.createSpace(name: "new_space")
            guard let newSpace = schema.spaces["new_space"] else {
                throw "new_space not found"
            }
            assertEqual(newSpace.id, 512)
            assertEqual(newSpace.name, "new_space")

            try schema.createSpace(name: "another_space")
            guard let anotherSpace = schema.spaces["another_space"] else {
                throw "another_space not found"
            }
            assertEqual(anotherSpace.id, 513)
            assertEqual(anotherSpace.name, "another_space")
        } catch {
            fail(String(describing: error))
        }
    }

    func testCreateIndex() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))

            try schema.createSpace(name: "new_space")

            let tree = try schema.createIndex(name: "tree", in: "new_space")
            let expected0 =
                Index(id: 0, name: "tree", type: .tree, unique: true)
            assertEqual(tree, expected0)

            let rtree = try schema.createIndex(
                name: "rtree", type: .rtree, in: "new_space")
            let expected1 =
                Index(id: 1, name: "rtree", type: .rtree, unique: false)
            assertEqual(rtree, expected1)

            let nonUnique = try schema.createIndex(
                name: "non_unique", unique: false, in: "new_space")
            let expected2 =
                Index(id: 2, name: "non_unique", type: .tree, unique: false)
            assertEqual(nonUnique, expected2)
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testSchema", testSchema),
        ("testCreateSpace", testCreateSpace),
        ("testCreateIndex", testCreateIndex),
    ]
}
