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
import Async
import TarantoolConnector
@testable import TestUtils

extension TarantoolProcess {
    convenience init(registerFunction function: String) throws {
        guard let module = Module("TarantoolModuleTest").path else {
            throw "can't find swift module"
        }

        let script = """
            package.cpath = '\(module);'..package.cpath
            require('TarantoolModuleTest')

            box.schema.user.grant('guest', 'read,write,execute', 'universe')
            box.schema.user.passwd('admin', 'admin')

            local test = box.schema.space.create('test')
            test:create_index('primary', {type = 'tree', parts = {1, 'unsigned'}})

            test:replace({1, 'foo'})
            test:replace({2, 'bar'})
            test:replace({3, 'baz'})

            local seq = box.schema.space.create('seq')
            seq:create_index('primary', {sequence=true})

            box.schema.func.create('\(function)', {language = 'C'})
            """

        try self.init(with: script)
        try launch()
    }

    static func testProcedure(
        _ name: String,
        _ file: StaticString = #file,
        _ line: UInt = #line)
    {
        async.task {
            scope(file: file, line: line) {
                let tarantool = try TarantoolProcess(registerFunction: name)
                let iproto = try IProto(host: "127.0.0.1", port: tarantool.port)
                _ = try iproto.call(name)

                let status = try tarantool.terminate()

                assertEqual(status, 0, file: file, line: line)
            }
        }
        async.loop.run()
    }
}
