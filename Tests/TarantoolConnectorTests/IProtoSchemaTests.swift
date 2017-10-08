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
import AsyncDispatch
@testable import TestUtils
@testable import TarantoolConnector

class IProtoSchemaTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProto!

    override func setUp() {
        do {
            AsyncDispatch().registerGlobal()
            tarantool = try TarantoolProcess(with: """
                box.schema.user.grant('guest', 'read,write,execute', 'universe')
                box.schema.user.passwd('admin', 'admin')
                """)
            try tarantool.launch()

            iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
        } catch {
            fatalError(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testSchema() {
        do {
            let schema = try Schema(iproto)

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
            try iproto.auth(username: "admin", password: "admin")
            var schema = try Schema(iproto)

            try schema.createSpace(name: "new_space")
            guard let newSpace = schema.spaces["new_space"] else {
                throw "new_space not found"
            }
            assertEqual(newSpace.id, 512)
            assertEqual(newSpace.name, "new_space")

            let anotherSpace = try schema.createSpace(name: "another_space")
            assertEqual(anotherSpace.id, 513)
            assertEqual(anotherSpace.name, "another_space")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testSchema", testSchema),
        ("testCreateSpace", testCreateSpace)
    ]
}
