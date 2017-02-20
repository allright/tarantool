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
import Foundation
@testable import TestUtils
@testable import TarantoolConnector

class IProtoDataSourceTests: TestCase {
    var tarantool: TarantoolProcess!
    var source: IProtoDataSource!
    var testId = 0

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
                let testId = Int(first) else {
                    fail()
                    return
            }
            self.testId = testId
        } catch {
            fail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testCount() {
        do {
            let result = try source.count(spaceId: testId, iterator: .all)
            assertEqual(result, 3)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            let result = try source.select(spaceId: testId, iterator: .all)
            assertEqual(result.count, 3)
            if result.count == 3 {
                assertEqual(result[0], Tuple([1, "foo"]))
                assertEqual(result[1], Tuple([2, "bar"]))
                assertEqual(result[2], Tuple([3, "baz"]))
            }
        } catch {
            fail(String(describing: error))
        }
    }

    func testGet() {
        do {
            guard let result =
                try source.get(spaceId: testId, keys: [3]) else {
                    fail()
                    return
            }
            assertEqual(result, [3, "baz"])
        } catch {
            fail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            try source.insert(spaceId: testId, tuple: [4, "quux"])
            guard let result =
                try source.get(spaceId: testId, keys: [4]) else {
                    fail()
                    return
            }
            assertEqual(result, [4, "quux"])
        } catch {
            fail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            try source.replace(spaceId: testId, tuple: [3, "zab"])
            guard let result =
                try source.get(spaceId: testId, keys: [3]) else {
                    fail()
                    return
            }
            assertEqual(result, [3, "zab"])
        } catch {
            fail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            try source.delete(spaceId: testId, keys: [3])
            assertNil(try source.get(spaceId: testId, keys: [3]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            try source.update(spaceId: testId, keys: [3], ops: [["=", 1, "zab"]])
            guard let result =
                try source.get(spaceId: testId, keys: [3]) else {
                    fail()
                    return
            }
            assertEqual(result, [3, "zab"])
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            assertNil(try source.get(spaceId: testId, keys: [4]))

            try source.upsert(spaceId: testId, tuple: [4, "quux", 42], ops: [["+", 2, 8]])
            guard let insertResult =
                try source.get(spaceId: testId, keys: [4]) else {
                    fail()
                    return
            }
            assertEqual(insertResult, [4, "quux", 42])

            try source.upsert(spaceId: testId, tuple: [4, "quux", 42], ops: [["+", 2, 8]])
            guard let updateResult =
                try source.get(spaceId: testId, keys: [4]) else {
                    fail()
                    return
            }
            assertEqual(updateResult, [4, "quux", 50])
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests : [(String, (IProtoDataSourceTests) -> () throws -> Void)] {
        return [
            ("testCount", testCount),
            ("testSelect", testSelect),
            ("testGet", testGet),
            ("testInsert", testInsert),
            ("testReplace", testReplace),
            ("testDelete", testDelete),
            ("testUpdate", testUpdate),
            ("testUpsert", testUpsert),
        ]
    }
}
