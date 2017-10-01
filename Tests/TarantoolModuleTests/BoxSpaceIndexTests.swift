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
import TarantoolConnector
@testable import TestUtils

class BoxSpaceIndexTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    let functions: ContiguousArray<String> = [
        "BoxSpaceIndexTests_testHash",
        "BoxSpaceIndexTests_testTree",
        "BoxSpaceIndexTests_testRTree",
        "BoxSpaceIndexTests_testBitset",
        "BoxSpaceIndexTests_testSequence",
        "BoxSpaceIndexTests_testMany"
    ]

    override func setUp() {
        do {
            AsyncDispatch().registerGlobal()
            guard let module = Module("TarantoolModuleTest").path else {
                fail("can't find swift module")
                return
            }

            let script = """
                package.cpath = '\(module);'..package.cpath
                require('TarantoolModuleTest')

                box.schema.user.grant('guest', 'read,write,execute', 'universe')
                box.schema.user.passwd('admin', 'admin')
                """ +
                functions.reduce("") {
                    """
                    \($0)
                    box.schema.func.create('\($1)', {language = 'C'})
                    """
            }

            tarantool = try TarantoolProcess(with: script)
            try tarantool.launch()

            iproto = try IProtoConnection(host: "127.0.0.1", port: tarantool.port)
        } catch {
            fail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testHash() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxSpaceIndexTests_testHash")
        } catch {
            fail(String(describing: error))
        }
    }

    func testTree() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxSpaceIndexTests_testTree")
        } catch {
            fail(String(describing: error))
        }
    }

    func testRTree() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxSpaceIndexTests_testRTree")
        } catch {
            fail(String(describing: error))
        }
    }

    func testBitset() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxSpaceIndexTests_testBitset")
        } catch {
            fail(String(describing: error))
        }
    }

    func testSequence() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxSpaceIndexTests_testSequence")
        } catch {
            fail(String(describing: error))
        }
    }

    func testMany() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxSpaceIndexTests_testMany")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testHash", testHash),
        ("testTree", testTree),
        ("testRTree", testRTree),
        ("testBitset", testBitset),
        ("testSequence", testSequence),
        ("testMany", testMany),
    ]
}
