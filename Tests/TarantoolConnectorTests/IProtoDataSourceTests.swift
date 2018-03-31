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
@testable import Async
@testable import TestUtils
@testable import TarantoolConnector

class IProtoDataSourceTests: TestCase {
    var tarantool: TarantoolProcess!
    var source: IProto!
    var testId = 0

    override func setUp() {
        do {
            async.setUp(Dispatch.self)
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

            let result = try source.eval("return box.space.test.id")
            guard let testId = result.first?.integerValue else {
                fail()
                return
            }
            self.testId = testId
        } catch {
            continueAfterFailure = false
            fail(String(describing: error))
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        assertEqual(status, 0)
    }

    func testCount() {
        scope {
            let result = try source.count(testId, 0, .all, [])
            assertEqual(result, 3)
        }
    }

    func testSelect() {
        scope {
            let expected: [IProto.Tuple] = [
                IProto.Tuple([1, "foo"]),
                IProto.Tuple([2, "bar"]),
                IProto.Tuple([3, "baz"])
            ]
            let result = try source.select(testId, 0, .all, [], 0, 1000)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testGet() {
        scope {
            let result = try source.get(testId, 0, [3])
            assertEqual(result, IProto.Tuple([3, "baz"]))
        }
    }

    func testInsert() {
        scope {
            try source.insert(testId, [4, "quux"])
            let result = try source.get(testId, 0, [4])
            assertEqual(result, IProto.Tuple([4, "quux"]))
        }
    }

    func testReplace() {
        scope {
            try source.replace(testId, [3, "zab"])
            let result = try source.get(testId, 0, [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testDelete() {
        scope {
            try source.delete(testId, 0, [3])
            assertNil(try source.get(testId, 0, [3]))
        }
    }

    func testUpdate() {
        scope {
            try source.update(testId, 0, [3], [["=", 1, "zab"]])
            let result = try source.get(testId, 0, [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testUpsert() {
        scope {
            assertNil(try source.get(testId, 0, [4]))

            try source.upsert(testId, 0, [4, "quux", 42], [["+", 2, 8]])
            let insertResult = try source.get(testId, 0, [4])
            assertEqual(insertResult, IProto.Tuple([4, "quux", 42]))

            try source.upsert(testId, 0, [4, "quux", 42], [["+", 2, 8]])
            let updateResult = try source.get(testId, 0, [4])
            assertEqual(updateResult, IProto.Tuple([4, "quux", 50]))
        }
    }
}
