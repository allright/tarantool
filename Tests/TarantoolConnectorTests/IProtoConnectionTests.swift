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
import Foundation
@testable import TestUtils
@testable import TarantoolConnector

class IProtoConnectionTests: XCTestCase {
    var tarantool: TarantoolProcess!
    var iproto: IProtoConnection!
    
    override func setUp() {
        do {
            tarantool = try TarantoolProcess(with:
                "box.schema.user.grant('guest', 'read,write,execute', 'universe')")
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

    func testPing() {
        do {
            try iproto.ping()
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testEval() {
        do {
            let result = try iproto.eval("return 'he'..'l'..'lo'")
            guard let first = result.first,
                let answer = String(first) else {
                    XCTFail()
                    return
            }
            XCTAssertEqual(answer, "hello")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testAuth() {
        do {
            _ = try iproto.eval(
                "box.schema.user.create('tester', {password='tester'})")
            try iproto.auth(username: "tester", password: "tester")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testCall() {
        do {
            _ = try iproto.eval(
                "box.schema.func.create('hello')\n" +
                "function hello()\n" +
                "  return 'hey there!'\n" +
                "end\n")
            let result = try iproto.call("hello")
            guard let first = result.first,
                let answer = String(first) else {
                    XCTFail()
                    return
            }
            XCTAssertEqual(answer, "hey there!")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testRequest() {
        do {
            let result = try iproto.request(code: .ping)
            XCTAssertEqual(result, [])
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (IProtoConnectionTests) -> () throws -> Void)] {
        return [
            ("testPing", testPing),
            ("testEval", testEval),
            ("testCall", testCall),
            ("testAuth", testAuth),
            ("testRequest", testRequest),
        ]
    }
}
