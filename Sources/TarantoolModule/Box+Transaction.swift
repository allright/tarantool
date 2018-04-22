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

import CTarantool

extension Box.API {
    struct Transaction {
        @inline(__always)
        fileprivate static func begin() throws {
            guard _box_txn_begin() == 0 else {
                throw Box.Error()
            }
        }

        @inline(__always)
        fileprivate static func commit() throws {
            guard _box_txn_commit() == 0 else {
                throw Box.Error()
            }
        }

        @inline(__always)
        fileprivate static func rollback() throws {
            guard _box_txn_rollback() == 0 else {
                throw Box.Error()
            }
        }
    }
}

extension Box {
    public static func transaction<T>(
        _ closure: () throws -> T
    ) throws -> T {
        try Box.API.Transaction.begin()

        do {
            let result = try closure()
            try Box.API.Transaction.commit()
            return result
        } catch {
            try Box.API.Transaction.rollback()
            throw error
        }
    }
}
