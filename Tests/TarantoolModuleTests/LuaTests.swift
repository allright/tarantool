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

class LuaTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProto!

    let functions: ContiguousArray<String> = [
        "LuaTests_testEval",
        "LuaTests_testPushPop",
        "LuaTests_testPushPopMany",
        "LuaTests_testPushPopArray",
        "LuaTests_testPushPopMap"
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
        let log = tarantool.log
        let status = tarantool.terminate()
        guard status == 0 else {
            fail(log ?? "")
            return
        }
    }

    func testEval() {
        scope {
            _ = try iproto.call("LuaTests_testEval")
        }
    }

    func testPushPop() {
        scope {
            _ = try iproto.call("LuaTests_testPushPop")
        }
    }

    func testPushPopMany() {
        scope {
            _ = try iproto.call("LuaTests_testPushPopMany")
        }
    }

    func testPushPopArray() {
        scope {
            _ = try iproto.call("LuaTests_testPushPopArray")
        }
    }

    func testPushPopMap() {
        scope {
            _ = try iproto.call("LuaTests_testPushPopMap")
        }
    }
}
