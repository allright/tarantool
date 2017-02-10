/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import XCTest
import TarantoolConnector
@testable import TestUtils
@testable import TarantoolModuleTest

class BoxTransactionTests: XCTestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    var functions = [
        "BoxTransactionTests_testTransactionCommit",
        "BoxTransactionTests_testTransactionRollback",
    ]

    override func setUp() {
        do {
            guard let module = Module("TarantoolModuleTest").path else {
                XCTFail("can't find swift module")
                return
            }

            let script =
                "package.cpath = '\(module);'..package.cpath\n" +
                "local ffi = require('ffi')\n" +
                "local lib = ffi.load('\(module)')\n" +
                "ffi.cdef[[void tarantool_module_init();]]\n" +
                "lib.tarantool_module_init()\n" +

                "box.schema.user.grant('guest', 'read,write,execute', 'universe')\n" +
                "local test = box.schema.space.create('test')\n" +
                "test:create_index('primary', {type = 'tree', parts = {1, 'unsigned'}})\n" +

                functions.reduce("") { $0 + "box.schema.func.create('\($1)', {language = 'C'})\n" }

            tarantool = try TarantoolProcess(with: script)
            try tarantool.launch()

            iproto = try IProtoConnection(host: "127.0.0.1", port: tarantool.port)
        } catch {
            XCTFail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        XCTAssertEqual(status, 0)
    }

    func testTransactionCommit() {
        do {
            _ = try iproto.call("BoxTransactionTests_testTransactionCommit")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testTransactionRollback() {
        do {
            _ = try iproto.call("BoxTransactionTests_testTransactionRollback")
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (BoxTransactionTests) -> () throws -> Void)] {
        return [
            ("testTransactionCommit", testTransactionCommit),
            ("testTransactionRollback", testTransactionRollback),
        ]
    }
}
