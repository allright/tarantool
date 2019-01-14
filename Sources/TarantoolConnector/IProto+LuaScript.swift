import MessagePack

extension IProto: LuaScript {
    public func call(
        _ function: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try request(
            code: .call,
            keys: [
                .functionName: .string(function),
                .tuple: .array(arguments)
            ]
        )
    }

    public func eval(
        _ expression: String,
        arguments: [MessagePack] = []
    ) throws -> [MessagePack] {
        return try request(
            code: .eval,
            keys: [
                .expression: .string(expression),
                .tuple: .array(arguments)
            ]
        )
    }
}
