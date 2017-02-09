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

class BoxSpaceTests: XCTestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    var functions = [
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
            _ = try iproto.call("BoxSpaceTests_testCount")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            _ = try iproto.call("BoxSpaceTests_testSelect")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testGet() {
        do {
            _ = try iproto.call("BoxSpaceTests_testGet")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            _ = try iproto.call("BoxSpaceTests_testInsert")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            _ = try iproto.call("BoxSpaceTests_testReplace")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            _ = try iproto.call("BoxSpaceTests_testDelete")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            _ = try iproto.call("BoxSpaceTests_testUpdate")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            _ = try iproto.call("BoxSpaceTests_testUpsert")
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (BoxSpaceTests) -> () throws -> Void)] {
        return [
            ("BoxSpaceTests_testCount", testCount),
            ("BoxSpaceTests_testSelect", testSelect),
            ("BoxSpaceTests_testGet", testGet),
            ("BoxSpaceTests_testInsert", testInsert),
            ("BoxSpaceTests_testReplace", testReplace),
            ("BoxSpaceTests_testDelete", testDelete),
            ("BoxSpaceTests_testUpdate", testUpdate),
            ("BoxSpaceTests_testUpsert", testUpsert),
        ]
    }
}