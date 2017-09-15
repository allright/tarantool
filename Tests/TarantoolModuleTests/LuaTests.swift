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

class LuaTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!

    let functions: ContiguousArray<String> = [
        "LuaTests_testEval",
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

    func testEval() {
        do {
            _ = try iproto.call("LuaTests_testEval")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testEval", testEval),
    ]
}
