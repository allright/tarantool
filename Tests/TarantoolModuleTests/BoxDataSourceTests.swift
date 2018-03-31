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

class BoxDataSourceTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProto!

    let functions: ContiguousArray<String> = [
        "BoxDataSourceTests_testCount",
        "BoxDataSourceTests_testSelect",
        "BoxDataSourceTests_testGet",
        "BoxDataSourceTests_testInsert",
        "BoxDataSourceTests_testReplace",
        "BoxDataSourceTests_testDelete",
        "BoxDataSourceTests_testUpdate",
        "BoxDataSourceTests_testUpsert"
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

    func testCount() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testCount")
        }
    }

    func testSelect() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testSelect")
        }
    }

    func testGet() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testGet")
        }
    }

    func testInsert() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testInsert")
        }
    }

    func testReplace() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testReplace")
        }
    }

    func testDelete() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testDelete")
        }
    }

    func testUpdate() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testUpdate")
        }
    }

    func testUpsert() {
        scope {
            _ = try iproto.call("BoxDataSourceTests_testUpsert")
        }
    }
}
