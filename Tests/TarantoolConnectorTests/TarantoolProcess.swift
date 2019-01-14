import File
import TarantoolConnector
@testable import TestUtils

extension TarantoolProcess {
    convenience init(at path: Path) throws {
        let script = """
        box.schema.user.grant('guest', 'read,write,execute', 'universe')
        box.schema.user.passwd('admin', 'admin')

        local test = box.schema.space.create('test')
        test:create_index('primary', {type = 'tree', parts = {1, 'unsigned'}})
        test:replace({1, 'foo'})
        test:replace({2, 'bar'})
        test:replace({3, 'baz'})

        local seq = box.schema.space.create('seq')
        seq:create_index('primary', {sequence=true})
        """

        try self.init(at: path, with: script)
        try launch()
    }

    func getTestSpaceId() throws -> Int {
        let iproto = try IProto(host: "127.0.0.1", port: port)

        let result = try iproto.eval("return box.space.test.id")
        guard let testId = result.first?.integerValue else {
            throw "can't get test space id"
        }
        return testId
    }
}
