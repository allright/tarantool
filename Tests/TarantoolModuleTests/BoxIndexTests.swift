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

class BoxIndexTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    let functions: ContiguousArray<String> = [
        "BoxIndexTests_testHash",
        "BoxIndexTests_testTree",
        "BoxIndexTests_testRTree",
        "BoxIndexTests_testBitset",
        "BoxIndexTests_testSequence",
        "BoxIndexTests_testMany",
        "BoxIndexTests_testCount",
        "BoxIndexTests_testSelect",
        "BoxIndexTests_testGet",
        "BoxIndexTests_testInsert",
        "BoxIndexTests_testReplace",
        "BoxIndexTests_testDelete",
        "BoxIndexTests_testUpdate",
        "BoxIndexTests_testUpsert"
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

                local test = box.schema.space.create('test')
                test:create_index('primary', {type = 'tree', parts = {1, 'unsigned'}})
                test:replace({1, 'foo'})
                test:replace({2, 'bar'})
                test:replace({3, 'baz'})
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
            fatalError(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testHash() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testHash")
        } catch {
            fail(String(describing: error))
        }
    }

    func testTree() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testTree")
        } catch {
            fail(String(describing: error))
        }
    }

    func testRTree() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testRTree")
        } catch {
            fail(String(describing: error))
        }
    }

    func testBitset() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testBitset")
        } catch {
            fail(String(describing: error))
        }
    }

    func testSequence() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testSequence")
        } catch {
            fail(String(describing: error))
        }
    }

    func testMany() {
        do {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testMany")
        } catch {
            fail(String(describing: error))
        }
    }

    func testCount() {
        do {
            _ = try iproto.call("BoxIndexTests_testCount")
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            _ = try iproto.call("BoxIndexTests_testSelect")
        } catch {
            fail(String(describing: error))
        }
    }

    func testGet() {
        do {
            _ = try iproto.call("BoxIndexTests_testGet")
        } catch {
            fail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            _ = try iproto.call("BoxIndexTests_testInsert")
        } catch {
            fail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            _ = try iproto.call("BoxIndexTests_testReplace")
        } catch {
            fail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            _ = try iproto.call("BoxIndexTests_testDelete")
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            _ = try iproto.call("BoxIndexTests_testUpdate")
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            _ = try iproto.call("BoxIndexTests_testUpsert")
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
        ("testCount", testCount),
        ("testSelect", testSelect),
        ("testGet", testGet),
        ("testInsert", testInsert),
        ("testReplace", testReplace),
        ("testDelete", testDelete),
        ("testUpdate", testUpdate),
        ("testUpsert", testUpsert),
    ]
}
