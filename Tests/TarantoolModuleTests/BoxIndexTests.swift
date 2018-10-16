/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

import Test
import File
import Fiber
@testable import Async
@testable import TestUtils

class BoxIndexTests: TestCase {
    let temp = Path(string: "/tmp/BoxIndexTests")

    override func setUp() {
        async.setUp(Fiber.self)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func test(
        _ name: String,
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ function: String = #function)
    {
        async.task { [unowned self] in
            scope(file: file, line: line) {
                let path = self.temp.appending(function)
                let tarantool = try TarantoolProcess(at: path, function: name)
                try tarantool.call(name)
            }
        }
        async.loop.run()
    }

    func testHash() {
        test("BoxIndexTests_testHash")
    }

    func testTree() {
        test("BoxIndexTests_testTree")
    }

    func testRTree() {
        test("BoxIndexTests_testRTree")
    }

    func testBitset() {
        test("BoxIndexTests_testBitset")
    }

    func testSequence() {
        test("BoxIndexTests_testSequence")
    }

    func testMany() {
        test("BoxIndexTests_testMany")
    }

    func testCount() {
        test("BoxIndexTests_testCount")
    }

    func testSelect() {
        test("BoxIndexTests_testSelect")
    }

    func testGet() {
        test("BoxIndexTests_testGet")
    }

    func testInsert() {
        test("BoxIndexTests_testInsert")
    }

    func testReplace() {
        test("BoxIndexTests_testReplace")
    }

    func testDelete() {
        test("BoxIndexTests_testDelete")
    }

    func testUpdate() {
        test("BoxIndexTests_testUpdate")
    }

    func testUpsert() {
        test("BoxIndexTests_testUpsert")
    }
}
