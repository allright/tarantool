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

class IProtoIteratorTests: TestCase {
    var tarantool: TarantoolProcess!
    var source: IProtoDataSource!
    var testSpaceId = 0

    override func setUp() {
        do {
            tarantool = try TarantoolProcess(with:
                "box.schema.user.grant('guest', 'read,write,execute', 'universe')\n" +
                "local test = box.schema.space.create('test')\n" +
                "test:create_index('primary', {type = 'tree', parts = {1, 'unsigned'}})\n" +
                "test:replace({1, 'foo'})\n" +
                "test:replace({2, 'bar'})\n" +
                "test:replace({3, 'baz'})")
            try tarantool.launch()

            let iproto = try IProtoConnection(host: "127.0.0.1", port: tarantool.port)
            source = IProtoDataSource(connection: iproto)

            guard let first = try iproto.eval("return box.space.test.id").first,
                let testSpaceId = Int(first) else {
                    fail()
                    return
            }
            self.testSpaceId = testSpaceId
        } catch {
            fail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testSelectAll() {
        do {
            let expected: [IProtoTuple] = [
                IProtoTuple(rawValue: [1, "foo"]),
                IProtoTuple(rawValue: [2, "bar"]),
                IProtoTuple(rawValue: [3, "baz"])
            ]
            let result = try source.select(testSpaceId, 0, .all, [], 0, 1000)
            assertEqual([IProtoTuple](result), expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelectEQ() {
        do {
            let expected: [IProtoTuple] = [
                IProtoTuple(rawValue: [2, "bar"])
            ]
            let result = try source.select(testSpaceId, 0, .eq, [2], 0, 1000)
            assertEqual([IProtoTuple](result), expected)

        } catch {
            fail(String(describing: error))
        }
    }

    func testSelectGT() {
        do {
            let expected: [IProtoTuple] = [
                IProtoTuple(rawValue: [3, "baz"])
            ]
            let result = try source.select(testSpaceId, 0, .gt, [2], 0, 1000)
            assertEqual([IProtoTuple](result), expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelectGE() {
        do {
            let expected: [IProtoTuple] = [
                IProtoTuple(rawValue: [2, "bar"]),
                IProtoTuple(rawValue: [3, "baz"])
            ]
            let result = try source.select(testSpaceId, 0, .ge, [2], 0, 1000)
            assertEqual([IProtoTuple](result), expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelectLT() {
        do {
            let expected: [IProtoTuple] = [
                IProtoTuple(rawValue: [1, "foo"])
            ]
            let result = try source.select(testSpaceId, 0, .lt, [2], 0, 1000)
            assertEqual([IProtoTuple](result), expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelectLE() {
        do {
            let expected: [IProtoTuple] = [
                IProtoTuple(rawValue: [2, "bar"]),
                IProtoTuple(rawValue: [1, "foo"])
            ]
            let result = try source.select(testSpaceId, 0, .le, [2], 0, 1000)
            assertEqual([IProtoTuple](result), expected)
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testSelectAll", testSelectAll),
        ("testSelectEQ", testSelectEQ),
        ("testSelectGT", testSelectGT),
        ("testSelectGE", testSelectGE),
        ("testSelectLT", testSelectLT),
        ("testSelectLE", testSelectLE),
    ]
}
