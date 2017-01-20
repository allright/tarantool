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
@testable import TarantoolConnector

class TarantoolConnectorTests: XCTestCase {
    let process = Process()

    override func setUp() {
        let script = "box.cfg{listen=3301}" +
            "box.schema.user.create('tester', { password = 'tester', if_not_exists = true })" +
            "box.schema.user.grant('tester', 'read,write,eval,execute', 'universe', nil, { if_not_exists = true })" +
            "local fiber = require('fiber')" +
            "fiber.sleep(3)" +
            "os.exit(0)"

        do {
            try script.write(toFile: "init.lua", atomically: true, encoding: .utf8)
        } catch {
            XCTFail(String(describing: error))
            return
        }

    #if os(macOS)
        process.launchPath = "/usr/local/bin/tarantool"
    #else
        process.launchPath = "/usr/bin/tarantool"
    #endif
        process.arguments = ["init.lua"]
        process.launch()
        sleep(1)
    }

    override func tearDown() {
        if process.isRunning {
            // not yet implemented
            // process.terminate()
        }
    }

    func testTarantoolConnector() {
        do {
            let iproto = try IProtoConnection(host: "127.0.0.1")
            try iproto.auth(username: "tester", password: "tester")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    
    static var allTests : [(String, (TarantoolConnectorTests) -> () throws -> Void)] {
        return [
            ("testTarantoolConnector", testTarantoolConnector),
        ]
    }
}
