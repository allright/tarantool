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
@testable import TarantoolProcess
@testable import TarantoolConnector

class TarantoolConnectorTests: XCTestCase {
    var tarantool: TarantoolProcess?

    override func setUp() {
        do {
            tarantool = try TarantoolProcess()
            try tarantool?.launch()
        } catch {
            XCTFail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool?.terminate()
        XCTAssertEqual(status, 0)
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
