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

class BoxDataSourceTests: XCTestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    var functions = [
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
                "test:replace({1, 'foo'})\n" +
                "test:replace({2, 'bar'})\n" +
                "test:replace({3, 'baz'})\n" +

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

    func testCount() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testCount")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testSelect")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testGet() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testGet")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testInsert")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testReplace")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testDelete")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testUpdate")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            _ = try iproto.call("BoxDataSourceTests_testUpsert")
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (BoxDataSourceTests) -> () throws -> Void)] {
        return [
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
}
