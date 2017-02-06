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

class SpaceTests: XCTestCase {
    var tarantool: TarantoolProcess!
    var space: Space!

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

            let iproto = try IProtoConnection(host: "127.0.0.1")
            let space = IProtoDataSource(connection: iproto)
            let schema = try Schema(space)

            self.space = schema.spaces["test"]
        } catch {
            XCTFail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        XCTAssertEqual(status, 0)
    }

    func testCount() {
        do {
            let result = try space.count(.all)
            XCTAssertEqual(result, 3)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSelect() {
        do {
            let result = try space.select(.all)
            XCTAssertEqual(result.count, 3)
            if result.count == 3 {
                XCTAssertEqual(result[0], Tuple([1, "foo"]))
                XCTAssertEqual(result[1], Tuple([2, "bar"]))
                XCTAssertEqual(result[2], Tuple([3, "baz"]))
            }
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testGet() {
        do {
            guard let result = try space.get([3]) else {
                XCTFail()
                return
            }
            XCTAssertEqual(result, [3, "baz"])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInsert() {
        do {
            try space.insert([4, "quux"])
            guard let result = try space.get([4]) else {
                XCTFail()
                return
            }
            XCTAssertEqual(result, [4, "quux"])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testReplace() {
        do {
            try space.replace([3, "zab"])
            guard let result = try space.get([3]) else {
                XCTFail()
                return
            }
            XCTAssertEqual(result, [3, "zab"])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDelete() {
        do {
            try space.delete([3])
            XCTAssertNil(try space.get([3]))
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUpdate() {
        do {
            try space.update([3], ops: [["=", 1, "zab"]])
            guard let result = try space.get([3]) else {
                XCTFail()
                return
            }
            XCTAssertEqual(result, [3, "zab"])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUpsert() {
        do {
            XCTAssertNil(try space.get([4]))

            try space.upsert([4, "quux", 42], ops: [["+", 2, 8]])
            guard let insertResult = try space.get([4]) else {
                XCTFail()
                return
            }
            XCTAssertEqual(insertResult, [4, "quux", 42])

            try space.upsert([4, "quux", 42], ops: [["+", 2, 8]])
            guard let updateResult = try space.get([4]) else {
                XCTFail()
                return
            }
            XCTAssertEqual(updateResult, [4, "quux", 50])
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (SpaceTests) -> () throws -> Void)] {
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
