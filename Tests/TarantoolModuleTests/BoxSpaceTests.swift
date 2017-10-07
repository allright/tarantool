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

class BoxSpaceTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    let functions: ContiguousArray<String> = [
        "BoxSpaceTests_testCount",
        "BoxSpaceTests_testSelect",
        "BoxSpaceTests_testGet",
        "BoxSpaceTests_testInsert",
        "BoxSpaceTests_testReplace",
        "BoxSpaceTests_testDelete",
        "BoxSpaceTests_testUpdate",
        "BoxSpaceTests_testUpsert"
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

    func testCount() {
        do {
            _ = try iproto.call("BoxSpaceTests_testCount")
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            _ = try iproto.call("BoxSpaceTests_testSelect")
        } catch {
            fail(String(describing: error))
        }
    }

    func testGet() {
        do {
            _ = try iproto.call("BoxSpaceTests_testGet")
        } catch {
            fail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            _ = try iproto.call("BoxSpaceTests_testInsert")
        } catch {
            fail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            _ = try iproto.call("BoxSpaceTests_testReplace")
        } catch {
            fail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            _ = try iproto.call("BoxSpaceTests_testDelete")
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            _ = try iproto.call("BoxSpaceTests_testUpdate")
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            _ = try iproto.call("BoxSpaceTests_testUpsert")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
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
