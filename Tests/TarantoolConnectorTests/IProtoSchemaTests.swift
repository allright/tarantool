/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Foundation
@testable import TestUtils
@testable import TarantoolConnector

class IProtoSchemaTests: TestCase {
    var tarantool: TarantoolProcess!
    var source: IProtoDataSource!

    override func setUp() {
        do {
            tarantool = try TarantoolProcess(with:
                "box.schema.user.grant('guest', 'read,write,execute', 'universe')\n" +
                "box.schema.space.create('space1')\n" +
                "box.schema.space.create('space2')")
            try tarantool.launch()

            let iproto = try IProtoConnection(host: "127.0.0.1", port: tarantool.port)
            source = IProtoDataSource(connection: iproto)
        } catch {
            fail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testSchema() {
        do {
            let schema = try Schema(source)

            let space1 = schema.spaces["space1"]
            assertNotNil(space1)

            let space2 = schema.spaces["space2"]
            assertNotNil(space2)
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testSchema", testSchema),
    ]
}
