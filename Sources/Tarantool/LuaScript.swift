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
