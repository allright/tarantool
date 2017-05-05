/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Foundation
@testable import TestUtils
@testable import TarantoolConnector

class IProtoSchemaTests: TestCase {
    var tarantool: TarantoolProcess!
    var connection: IProtoConnection!

    override func setUp() {
        do {
            tarantool = try TarantoolProcess(with:
                "box.schema.user.grant('guest', 'read,write,execute', 'universe')\n" +
                "box.schema.user.passwd('admin', 'admin')")
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

            try schema.createSpace(name: "another_space")
            guard let anotherSpace = schema.spaces["another_space"] else {
                throw "another_space not found"
            }
            assertEqual(anotherSpace.id, 513)
        } catch {
            fail(String(describing: error))
        }
    }

    func testCreateIndex() {
        do {
            try connection.auth(username: "admin", password: "admin")
            var schema = try Schema(IProto(connection: connection))

            try schema.createSpace(name: "new_space")

            let index1 = try schema.createIndex(
                name: "primary", in: "new_space")
            let expected1 = Index(
                id: 0, name: "primary", type: .tree, unique: true)
            assertEqual(index1, expected1)

            let index2 =
                try schema.createIndex(name: "another", in: "new_space")
            let expected2 = Index(
                id: 1, name: "another", type: .tree, unique: true)
            assertEqual(index2, expected2)

            let index3 = try schema.createIndex(
                name: "rtree", type: .rtree, in: "new_space")
            let expected3 = Index(
                id: 2, name: "rtree", type: .rtree, unique: false)
            assertEqual(index3, expected3)
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
