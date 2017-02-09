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

class IProtoSchemaTests: XCTestCase {
    var tarantool: TarantoolProcess!
    var iprotoSource: IProtoDataSource!

    override func setUp() {
        do {
            tarantool = try TarantoolProcess(with:
                "box.schema.user.grant('guest', 'read,write,execute', 'universe')\n" +
                "box.schema.space.create('space1')\n" +
                "box.schema.space.create('space2')")
            try tarantool.launch()

            let iproto = try IProtoConnection(host: "127.0.0.1", port: tarantool.port)
            iprotoSource = IProtoDataSource(connection: iproto)
        } catch {
            XCTFail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        XCTAssertEqual(status, 0)
    }

    func testSchema() {
        do {
            let schema = try Schema(iprotoSource)

            let space1 = schema.spaces["space1"]
            XCTAssertNotNil(space1)

            let space2 = schema.spaces["space2"]
            XCTAssertNotNil(space2)
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (IProtoSchemaTests) -> () throws -> Void)] {
        return [
            ("testSchema", testSchema),
        ]
    }
}
