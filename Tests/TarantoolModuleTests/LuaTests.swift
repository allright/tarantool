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

            iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
        } catch {
            fatalError(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        defer { tarantool.cleanup() }
        guard status == 0 else {
            fail(tarantool.log ?? "")
            return
        }
    }

    func testEval() {
        do {
            _ = try iproto.call("LuaTests_testEval")
        } catch {
            fail(String(describing: error))
        }
    }

    func testPushPop() {
        do {
             _ = try iproto.call("LuaTests_testPushPop")
        } catch {
            fail(String(describing: error))
        }
    }

    func testPushPopMany() {
        do {
            _ = try iproto.call("LuaTests_testPushPopMany")
        } catch {
            fail(String(describing: error))
        }
    }

    func testPushPopArray() {
        do {
            _ = try iproto.call("LuaTests_testPushPopArray")
        } catch {
            fail(String(describing: error))
        }
    }

    func testPushPopMap() {
        do {
            _ = try iproto.call("LuaTests_testPushPopMap")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testEval", testEval),
        ("testPushPop", testPushPop),
        ("testPushPopMany", testPushPopMany),
        ("testPushPopArray", testPushPopArray),
        ("testPushPopMap", testPushPopMap),
    ]
}
