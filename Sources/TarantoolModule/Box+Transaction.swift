import CTarantool

extension Box.API {
    struct Transaction {
        @inline(__always)
        fileprivate static func begin() throws {
            guard box_txn_begin() == 0 else {
                throw Box.Error()
            }
        }

        @inline(__always)
        fileprivate static func commit() throws {
            guard box_txn_commit() == 0 else {
                throw Box.Error()
            }
        }

        @inline(__always)
        fileprivate static func rollback() throws {
            guard box_txn_rollback() == 0 else {
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
