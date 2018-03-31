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

class IProtoSpaceTests: TestCase {
    var tarantool: TarantoolProcess!
    var space: Space<IProto>!
    var seq: Space<IProto>!

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

                local seq = box.schema.space.create('seq')
                seq:create_index('primary', {sequence=true})
                """)
            try tarantool.launch()

            let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
            let schema = try Schema(iproto)

            self.space = schema.spaces["test"]
            self.seq = schema.spaces["seq"]
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
            let result = try space.count(.all)
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
            let result = try space.select(iterator: .all)
            assertEqual([IProto.Tuple](result), expected)
        }
    }

    func testGet() {
        scope {
            let result = try space.get(keys: [3])
            assertEqual(result, IProto.Tuple([3, "baz"]))
        }
    }

    func testInsert() {
        scope {
            try space.insert([4, "quux"])
            let result = try space.get(keys: [4])
            assertEqual(result, IProto.Tuple([4, "quux"]))
        }
    }

    func testReplace() {
        scope {
            try space.replace([3, "zab"])
            let result = try space.get(keys: [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testDelete() {
        scope {
            try space.delete(keys: [3])
            assertNil(try space.get(keys: [3]))
        }
    }

    func testUpdate() {
        scope {
            try space.update(keys: [3], operations: [["=", 1, "zab"]])
            let result = try space.get(keys: [3])
            assertEqual(result, IProto.Tuple([3, "zab"]))
        }
    }

    func testUpsert() {
        scope {
            assertNil(try space.get(keys: [4]))

            try space.upsert([4, "quux", 42], operations: [["+", 2, 8]])
            let insertResult = try space.get(keys: [4])
            assertEqual(insertResult, IProto.Tuple([4, "quux", 42]))

            try space.upsert([4, "quux", 42], operations: [["+", 2, 8]])
            let updateResult = try space.get(keys: [4])
            assertEqual(updateResult, IProto.Tuple([4, "quux", 50]))
        }
    }

    func testSequence() {
        scope {
            var id = try seq.insert([nil, "foo"])
            assertEqual(id, 1)

            id = try seq.insert([nil, "bar"])
            assertEqual(id, 2)

            let result = try seq.get(keys: [id])
            assertEqual(result, IProto.Tuple([2, "bar"]))

        }
    }
}
