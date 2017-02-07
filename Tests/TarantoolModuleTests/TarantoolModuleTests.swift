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

class TarantoolModuleTests: XCTestCase {
    var port: UInt16 = 3302
    var tarantool: TarantoolProcess!

    var functions = [
        "testBox"
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
                "box.schema.user.grant('guest', 'read,write,eval,execute', 'universe')\n" +
                functions.reduce("") { $0 + "box.schema.func.create('\($1)', {language = 'C'})\n" }
            
            tarantool = try TarantoolProcess(with: script, listen: port)
            try tarantool.launch()
        } catch {
            XCTFail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        XCTAssertEqual(status, 0)
    }

    func testBox() {
        do {
            let iproto = try IProtoConnection(host: "127.0.0.1", port: port)
            let result = try iproto.call("testBox")
            guard let first = Tuple(result.first)?.first, let tuple = [MessagePack : MessagePack](first) else {
                throw TarantoolError.invalidTuple(message: "unexpected result")
            }
            XCTAssertEqual(tuple["success"], true)
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (TarantoolModuleTests) -> () throws -> Void)] {
        return [
            ("testBox", testBox),
        ]
    }
}
