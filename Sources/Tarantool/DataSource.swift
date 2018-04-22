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

public protocol DataSource {
    associatedtype Row: Tarantool.Tuple

    func count(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [IndexKey]
    ) throws -> Int

    func select(
        _ spaceId: Int,
        _ indexId: Int,
        _ iterator: Iterator,
        _ keys: [IndexKey],
        _ offset: Int,
        _ limit: Int
    ) throws -> AnySequence<Row>

    func get(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [IndexKey]
    ) throws -> Row?

    func insert(
        _ spaceId: Int,
        _ tuple: [MessagePack]
    ) throws -> MessagePack

    func replace(
        _ spaceId: Int,
        _ tuple: [MessagePack]
    ) throws

    func delete(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [IndexKey]
    ) throws

    func update(
        _ spaceId: Int,
        _ indexId: Int,
        _ keys: [IndexKey],
        _ ops: [MessagePack]
    ) throws

    func upsert(
        _ spaceId: Int,
        _ indexId: Int,
        _ tuple: [MessagePack],
        _ ops: [MessagePack]
    ) throws
}
