import Test
import File
import Async
import TarantoolConnector
@testable import TestUtils

extension TarantoolProcess {
    convenience init(at path: Path, function: String) throws {
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

        try self.init(at: path, with: script)
        try launch()
    }

    func call(
        _ name: String,
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ function: StaticString = #function) throws
    {
        let iproto = try IProto(host: "127.0.0.1", port: self.port)
        try iproto.auth(username: "admin", password: "admin")
        _ = try iproto.call(name)

        let status = try self.terminate()

        assertEqual(status, 0, file: file, line: line)
    }
}
