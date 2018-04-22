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

extension Tarantool {
    public enum Error: Swift.Error {
        case spaceNotFound
        case indexNotFound
        case invalidSchema
        case invalidEngine
        case invalidIndex(message: String)
        case invalidTuple(message: String)
        case notEnoughMemory
        case unexpected(message: String)
    }
}
