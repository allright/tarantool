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
@testable import Async
import TarantoolConnector
@testable import TestUtils

class BoxIndexTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProto!

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
            async.setUp(Dispatch.self)
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

            iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
        } catch {
            continueAfterFailure = false
            fail(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testHash() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testHash")
        }
    }

    func testTree() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testTree")
        }
    }

    func testRTree() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testRTree")
        }
    }

    func testBitset() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testBitset")
        }
    }

    func testSequence() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testSequence")
        }
    }

    func testMany() {
        scope {
            try iproto.auth(username: "admin", password: "admin")
            _ = try iproto.call("BoxIndexTests_testMany")
        }
    }

    func testCount() {
        scope {
            _ = try iproto.call("BoxIndexTests_testCount")
        }
    }

    func testSelect() {
        scope {
            _ = try iproto.call("BoxIndexTests_testSelect")
        }
    }

    func testGet() {
        scope {
            _ = try iproto.call("BoxIndexTests_testGet")
        }
    }

    func testInsert() {
        scope {
            _ = try iproto.call("BoxIndexTests_testInsert")
        }
    }

    func testReplace() {
        scope {
            _ = try iproto.call("BoxIndexTests_testReplace")
        }
    }

    func testDelete() {
        scope {
            _ = try iproto.call("BoxIndexTests_testDelete")
        }
    }

    func testUpdate() {
        scope {
            _ = try iproto.call("BoxIndexTests_testUpdate")
        }
    }

    func testUpsert() {
        scope {
            _ = try iproto.call("BoxIndexTests_testUpsert")
        }
    }
}
