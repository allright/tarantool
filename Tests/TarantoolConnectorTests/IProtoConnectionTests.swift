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
@testable import TarantoolConnector

class IProtoConnectionTests: TestCase {
    let temp = Path("/tmp/IProtoConnectionTests")

    override func setUp() {
        async.setUp(Fiber.self)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func withNewIProtoConnection(
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ function: StaticString = #function,
        _ body: @escaping (IProto) throws -> Void)
    {
        async.task {
            scope(file: file, line: line) {
                let temp = self.temp.appending("tarantool_\(function)")
                let tarantool = try TarantoolProcess(at: temp)
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                try body(iproto)
            }
        }
        async.loop.run()
    }

    func testPing() {
        withNewIProtoConnection { iproto in
            try iproto.ping()
        }
    }

    func testEval() {
        withNewIProtoConnection { iproto in
            let result = try iproto.eval("return 'he'..'l'..'lo'")
            assertEqual(result.first?.stringValue, "hello")
        }
    }

    func testAuth() {
        withNewIProtoConnection { iproto in
            _ = try iproto.eval(
                "box.schema.user.create('tester', {password='tester'})")
            try iproto.auth(username: "tester", password: "tester")
        }
    }

    func testCall() {
        withNewIProtoConnection { iproto in
            _ = try iproto.eval("""
                    box.schema.func.create('hello')
                    function hello()
                      return 'hey there!'
                    end
                    """)
            let result = try iproto.call("hello")
            assertEqual(result.first?.stringValue, "hey there!")
        }
    }

    func testRequest() {
        withNewIProtoConnection { iproto in
            let result = try iproto.request(code: .ping)
            assertEqual(result, [])
        }
    }
}
