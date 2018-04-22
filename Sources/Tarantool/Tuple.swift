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

public struct Tarantool {
    public typealias Tuple = TupleProtocol
}

public protocol TupleProtocol: RandomAccessCollection {
    var count: Int { get }
    subscript(index: Int) -> MessagePack? { get }
}
