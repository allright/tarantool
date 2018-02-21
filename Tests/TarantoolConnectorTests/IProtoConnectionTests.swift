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
@testable import TestUtils
@testable import TarantoolConnector

class IProtoConnectionTests: TestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProto!
    
    override func setUp() {
        do {
            async.setUp()
            tarantool = try TarantoolProcess(with:
                "box.schema.user.grant('guest', 'read,write,execute', 'universe')")
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

    func testPing() {
        do {
            try iproto.ping()
        } catch {
            fail(String(describing: error))
        }
    }

    func testEval() {
        do {
            let result = try iproto.eval("return 'he'..'l'..'lo'")
            guard let first = result.first,
                let answer = String(first) else {
                    fail()
                    return
            }
            assertEqual(answer, "hello")
        } catch {
            fail(String(describing: error))
        }
    }

    func testAuth() {
        do {
            _ = try iproto.eval(
                "box.schema.user.create('tester', {password='tester'})")
            try iproto.auth(username: "tester", password: "tester")
        } catch {
            fail(String(describing: error))
        }
    }

    func testCall() {
        do {
            _ = try iproto.eval("""
                box.schema.func.create('hello')
                function hello()
                  return 'hey there!'
                end
                """)
            let result = try iproto.call("hello")
            guard let first = result.first,
                let answer = String(first) else {
                    fail()
                    return
            }
            assertEqual(answer, "hey there!")
        } catch {
            fail(String(describing: error))
        }
    }

    func testRequest() {
        do {
            let result = try iproto.request(code: .ping)
            assertEqual(result, [])
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testPing", testPing),
        ("testEval", testEval),
        ("testCall", testCall),
        ("testAuth", testAuth),
        ("testRequest", testRequest),
    ]
}
