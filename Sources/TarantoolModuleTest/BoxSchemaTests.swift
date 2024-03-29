import Platform
import MessagePack
import TarantoolModule

struct BoxSchemaTests {
    static func testSchema() throws {
        let schema = try Schema(Box())
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
            try assertEqualThrows(spaces[key]?.id, value)
        }
    }

    static func testCreateSpace() throws {
        let schema = try Schema(Box())

        try schema.createSpace(name: "new_space")
        guard let newSpace = schema.spaces["new_space"] else {
            throw "new_space not found"
        }
        try assertTrueThrows(newSpace.id > 0)
        try assertEqualThrows(newSpace.name, "new_space")
        try assertEqualThrows(newSpace.engine, .memtx)

        let anotherSpace = try schema.createSpace(name: "another_space")
        try assertTrueThrows(anotherSpace.id > 0)
        try assertNotEqualThrows(anotherSpace.id, newSpace.id)
        try assertEqualThrows(anotherSpace.name, "another_space")
        try assertEqualThrows(anotherSpace.engine, .memtx)

        let vinyl = try schema.createSpace(name: "vinyl", engine: .vinyl)
        try assertTrueThrows(vinyl.id > 0)
        try assertNotEqualThrows(vinyl.id, anotherSpace.id)
        try assertEqualThrows(vinyl.name, "vinyl")
        try assertEqualThrows(vinyl.engine, .vinyl)
    }
}

// C API Wrappers

@_silgen_name("BoxSchemaTests_testSchema")
public func BoxSchemaTests_testSchema(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxSchemaTests.testSchema()
    }
}

@_silgen_name("BoxSchemaTests_testCreateSpace")
public func BoxSchemaTests_testCreateSpace(context: Box.Context) -> Box.Result {
    return Box.execute {
        try BoxSchemaTests.testCreateSpace()
    }
}
