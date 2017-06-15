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
import TarantoolConnector
@testable import TestUtils

class BoxTransactionTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    let functions: ContiguousArray<String> = [
        "BoxTransactionTests_testTransactionCommit",
        "BoxTransactionTests_testTransactionRollback",
        "BoxTransactionTests_testGenericTransactionCommit",
        "BoxTransactionTests_testGenericTransactionRollback",
    ]

    override func setUp() {
        do {
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

    func testTransactionCommit() {
        do {
            _ = try iproto.call("BoxTransactionTests_testTransactionCommit")
        } catch {
            fail(String(describing: error))
        }
    }

    func testTransactionRollback() {
        do {
            _ = try iproto.call("BoxTransactionTests_testTransactionRollback")
        } catch {
            fail(String(describing: error))
        }
    }

    func testGenericTransactionCommit() {
        do {
            _ = try iproto.call("BoxTransactionTests_testGenericTransactionCommit")
        } catch {
            fail(String(describing: error))
        }
    }

    func testGenericTransactionRollback() {
        do {
            _ = try iproto.call("BoxTransactionTests_testGenericTransactionRollback")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testTransactionCommit", testTransactionCommit),
        ("testTransactionRollback", testTransactionRollback),
        ("testGenericTransactionCommit", testGenericTransactionCommit),
        ("testGenericTransactionRollback", testGenericTransactionRollback),
    ]
}
