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
import Async
import TarantoolConnector
@testable import TestUtils

class BoxTransactionTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProto!

    let functions: ContiguousArray<String> = [
        "BoxTransactionTests_testCommit",
        "BoxTransactionTests_testRollback",
        "BoxTransactionTests_testTCommit",
        "BoxTransactionTests_testTRollback",
    ]

    override func setUp() {
        do {
            async.setUp()
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

            iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
        } catch {
            fatalError(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testCommit() {
        do {
            _ = try iproto.call("BoxTransactionTests_testCommit")
        } catch {
            fail(String(describing: error))
        }
    }

    func testRollback() {
        do {
            _ = try iproto.call("BoxTransactionTests_testRollback")
        } catch {
            fail(String(describing: error))
        }
    }

    func testTCommit() {
        do {
            _ = try iproto.call("BoxTransactionTests_testTCommit")
        } catch {
            fail(String(describing: error))
        }
    }

    func testTRollback() {
        do {
            _ = try iproto.call("BoxTransactionTests_testTRollback")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testCommit", testCommit),
        ("testRollback", testRollback),
        ("testTCommit", testTCommit),
        ("testTRollback", testTRollback),
    ]
}
