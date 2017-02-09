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

class IProtoIteratorTests: XCTestCase {
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
                    XCTFail()
                    return
            }
            self.testSpaceId = testSpaceId
        } catch {
            XCTFail(String(describing: error))
            return
        }
    }

    override func tearDown() {
        let status = tarantool.terminate()
        XCTAssertEqual(status, 0)
    }

    func testSelectAll() {
        do {
            let result = try source.select(spaceId: testSpaceId, iterator: .all, keys: [])
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

    func testSelectEQ() {
        do {
            let result = try source.select(spaceId: testSpaceId, iterator: .eq, keys: [2])
            XCTAssertEqual(result.count, 1)
            if let tuple = result.first {
                XCTAssertEqual(tuple, Tuple([2, "bar"]))
            }
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSelectGT() {
        do {
            let result = try source.select(spaceId: testSpaceId, iterator: .gt, keys: [2])
            XCTAssertEqual(result.count, 1)
            if let tuple = result.first {
                XCTAssertEqual(tuple, Tuple([3, "baz"]))
            }
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSelectGE() {
        do {
            let result = try source.select(spaceId: testSpaceId, iterator: .ge, keys: [2])
            XCTAssertEqual(result.count, 2)
            if result.count == 2 {
                XCTAssertEqual(result[0], Tuple([2, "bar"]))
                XCTAssertEqual(result[1], Tuple([3, "baz"]))
            }
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSelectLT() {
        do {
            let result = try source.select(spaceId: testSpaceId, iterator: .lt, keys: [2])
            XCTAssertEqual(result.count, 1)
            if result.count == 1 {
                XCTAssertEqual(result[0], Tuple([1, "foo"]))
            }
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testSelectLE() {
        do {
            let result = try source.select(spaceId: testSpaceId, iterator: .le, keys: [2])
            XCTAssertEqual(result.count, 2)
            if result.count == 2 {
                XCTAssertEqual(result[0], Tuple([2, "bar"]))
                XCTAssertEqual(result[1], Tuple([1, "foo"]))
            }
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (IProtoIteratorTests) -> () throws -> Void)] {
        return [
            ("testSelectAll", testSelectAll),
            ("testSelectEQ", testSelectEQ),
            ("testSelectGT", testSelectGT),
            ("testSelectGE", testSelectGE),
            ("testSelectLT", testSelectLT),
            ("testSelectLE", testSelectLE),
        ]
    }
}
