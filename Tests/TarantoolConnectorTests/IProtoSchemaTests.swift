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

class IProtoSchemaTests: TestCase {
    let temp = Path("/tmp/IProtoSchemaTests")

    override func setUp() {
        async.setUp(Fiber.self)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func withNewIProtoConnection(
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ function: String = #function,
        _ body: @escaping (IProto) throws -> Void)
    {
        async.task { [unowned self] in
            scope(file: file, line: line) {
                let path = self.temp.appending(function)
                let tarantool = try TarantoolProcess(at: path)
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                try body(iproto)
                assertEqual(try? tarantool.terminate(), 0)
            }
        }
        async.loop.run()
    }

    func testSchema() {
        withNewIProtoConnection { iproto in
            let schema = try Schema(iproto)

            guard schema.spaces.count > 0 else {
                throw "schema.spaces.count == 0"
            }
            let spaces = schema.spaces
            let expexted = [
                "_schema": 272,
                "_space": 280,
                "_vspace": 281,
                "_index": 288,
                "_vindex": 289,
                "_func": 296,
                "_vfunc": 297,
                "_user": 304,
                "_vuser": 305,
                "_priv": 312,
                "_vpriv": 313,
                "_cluster": 320,
            ]
            for (key, value) in expexted {
                assertEqual(spaces[key]?.id, value)
            }
        }
    }

    func testCreateSpace() {
        withNewIProtoConnection { iproto in
            try iproto.auth(username: "admin", password: "admin")
            let schema = try Schema(iproto)

            try schema.createSpace(name: "new_space")
            guard let newSpace = schema.spaces["new_space"] else {
                throw "new_space not found"
            }
            assertTrue(newSpace.id > 0)
            assertEqual(newSpace.name, "new_space")
            assertEqual(newSpace.engine, .memtx)

            let anotherSpace = try schema.createSpace(name: "another_space")
            assertTrue(anotherSpace.id > 0)
            assertNotEqual(anotherSpace.id, newSpace.id)
            assertEqual(anotherSpace.name, "another_space")
            assertEqual(anotherSpace.engine, .memtx)

            let vinyl = try schema.createSpace(name: "vinyl", engine: .vinyl)
            assertTrue(vinyl.id > 0)
            assertNotEqual(vinyl.id, anotherSpace.id)
            assertEqual(vinyl.name, "vinyl")
            assertEqual(vinyl.engine, .vinyl)
        }
    }
}
