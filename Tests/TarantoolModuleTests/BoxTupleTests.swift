/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import TarantoolConnector
@testable import TestUtils
@testable import TarantoolModuleTest

class BoxTupleTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    let functions: ContiguousArray<String> = [
        "BoxTupleTests_testUnpackTuple",
    ]

    override func setUp() {
        do {
            guard let module = Module("TarantoolModuleTest").path else {
                fail("can't find swift module")
                return
            }

            let script =
                "package.cpath = '\(module);'..package.cpath\n" +
                "local ffi = require('ffi')\n" +
                "local lib = ffi.load('\(module)')\n" +
                "ffi.cdef[[void tarantool_module_init();]]\n" +
                "lib.tarantool_module_init()\n" +

                "box.schema.user.grant('guest', 'read,write,execute', 'universe')\n" +

                functions.reduce("") { $0 + "box.schema.func.create('\($1)', {language = 'C'})\n" }

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

    func testUnpackTuple() {
        do {
            _ = try iproto.call("BoxTupleTests_testUnpackTuple")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests : [(String, (BoxTupleTests) -> () throws -> Void)] {
        return [
            ("testUnpackTuple", testUnpackTuple),
        ]
    }
}