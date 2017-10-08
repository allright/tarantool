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
@testable import TestUtils
@testable import TarantoolConnector

class IProtoDataSourceTests: TestCase {
    var tarantool: TarantoolProcess!
    var source: IProto!
    var testId = 0

    override func setUp() {
        do {
            AsyncDispatch().registerGlobal()
            tarantool = try TarantoolProcess(with: """
                box.schema.user.grant('guest', 'read,write,execute', 'universe')
                local test = box.schema.space.create('test')
                test:create_index('primary', {type = 'tree', parts = {1, 'unsigned'}})
                test:replace({1, 'foo'})
                test:replace({2, 'bar'})
                test:replace({3, 'baz'})
                """)
            try tarantool.launch()

            source = try IProto(host: "127.0.0.1", port: tarantool.port)

            guard let first = try source.eval("return box.space.test.id").first,
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
            let result = try source.count(testId, 0, .all, [])
            assertEqual(result, 3)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"]),
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            let result = try source.select(testId, 0, .all, [], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        } catch {
            fail(String(describing: error))
        }
    }

    func testGet() {
        do {
            guard let result =
                try source.get(testId, 0, [3]) else {
                    fail()
                    return
            }
            assertEqual(result, IProto.Tuple([3, "baz"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            try source.insert(testId, [4, "quux"])
            guard let result =
                try source.get(testId, 0, [4]) else {
                    fail()
                    return
            }
            assertEqual(result, IProto.Tuple([4, "quux"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            try source.replace(testId, [3, "zab"])
            guard let result =
                try source.get(testId, 0, [3]) else {
                    fail()
                    return
            }
            assertEqual(result, IProto.Tuple([3, "zab"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            try source.delete(testId, 0, [3])
            assertNil(try source.get(testId, 0, [3]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            try source.update(testId, 0, [3], [["=", 1, "zab"]])
            guard let result =
                try source.get(testId, 0, [3]) else {
                    fail()
                    return
            }
            assertEqual(result, IProto.Tuple([3, "zab"]))
        } catch {
            fail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            assertNil(try source.get(testId, 0, [4]))

            try source.upsert(testId, 0, [4, "quux", 42], [["+", 2, 8]])
            guard let insertResult =
                try source.get(testId, 0, [4]) else {
                    fail()
                    return
            }
            assertEqual(insertResult, IProto.Tuple([4, "quux", 42]))

            try source.upsert(testId, 0, [4, "quux", 42], [["+", 2, 8]])
            guard let updateResult =
                try source.get(testId, 0, [4]) else {
                    fail()
                    return
            }
            assertEqual(updateResult, IProto.Tuple([4, "quux", 50]))
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
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
