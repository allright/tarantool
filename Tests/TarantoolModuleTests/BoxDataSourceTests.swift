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

class BoxDataSourceTests: TestCase {
    let temp = Path(string: "/tmp/BoxDataSourceTests")

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

    func testCount() {
        test("BoxDataSourceTests_testCount")
    }

    func testSelect() {
        test("BoxDataSourceTests_testSelect")
    }

    func testLimit() {
        test("BoxDataSourceTests_testLimit")
    }

    func testGet() {
        test("BoxDataSourceTests_testGet")
    }

    func testInsert() {
        test("BoxDataSourceTests_testInsert")
    }

    func testReplace() {
        test("BoxDataSourceTests_testReplace")
    }

    func testDelete() {
        test("BoxDataSourceTests_testDelete")
    }

    func testUpdate() {
        test("BoxDataSourceTests_testUpdate")
    }

    func testUpsert() {
        test("BoxDataSourceTests_testUpsert")
    }
}
