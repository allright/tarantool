
import MessagePack

public protocol LuaScript {
    func call(
        _ function: String,
        arguments: [MessagePack]
    ) throws -> [MessagePack]

    func eval(
        _ expression: String,
        arguments: [MessagePack]
    ) throws -> [MessagePack]
}
