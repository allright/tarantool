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
