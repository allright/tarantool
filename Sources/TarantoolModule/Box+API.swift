import CTarantool

extension Box {
    struct API {
        static func count(
            _ spaceId: UInt32,
            _ indexId: UInt32,
            _ iterator: Iterator,
            _ keys: [UInt8]
        ) throws -> Int {
            let count = box_index_count(
                spaceId,
                indexId,
                Int32(iterator.rawValue),
                UnsafePointer<CChar>(keys),
                UnsafePointer<CChar>(keys) + keys.count)
            guard count >= 0 else {
                throw Error()
            }
            return count
        }

        static func select(
            _ spaceId: UInt32,
            _ indexId: UInt32,
            _ iterator: Iterator,
            _ keys: [UInt8],
            _ offset: Int,
            _ limit: Int
        ) throws -> AnySequence<Box.Tuple> {
            guard let iterator = Box.IndexIterator(
                spaceId,
                indexId,
                Int32(iterator.rawValue),
                UnsafePointer<CChar>(keys),
                UnsafePointer<CChar>(keys) + keys.count,
                offset,
                limit)
            else {
                throw Error()
            }
            return AnySequence { iterator }
        }

        static func get(
            _ spaceId: UInt32, _ indexId: UInt32, _ keys: [UInt8]
        ) throws -> Box.Tuple? {
            var result: OpaquePointer?
            guard box_index_get(
                spaceId,
                indexId,
                UnsafePointer<CChar>(keys),
                UnsafePointer<CChar>(keys)+keys.count,
                &result) == 0
            else {
                throw Error()
            }
            guard let tuple = result else {
                return nil
            }
            return Tuple(tuple)
        }

        static func insert(
            _ spaceId: UInt32,
            _ tuple: [UInt8]
        ) throws -> Box.Tuple {
            let pointer = try copyToInternalMemory(tuple)
            var result: OpaquePointer?
            guard box_insert(
                spaceId,
                pointer,
                pointer+tuple.count,
                &result) == 0
            else {
                throw Error()
            }
            guard let tuple = result else {
                throw Error(code: .unknown, message: "box_insert result is nil")
            }
            return Tuple(tuple)
        }

        static func max(
            _ spaceId: UInt32, _ indexId: UInt32, _ keys: [UInt8]
        ) throws -> Int? {
            var result: OpaquePointer?
            let pKeys = UnsafePointer<CChar>(keys)
            let pKeysEnd = pKeys + keys.count
            guard box_index_max(
                spaceId, indexId, pKeys, pKeysEnd, &result) == 0 else {
                    throw Error()
            }
            guard let pointer = result else {
                return nil
            }
            let tuple = Tuple(pointer)
            return tuple[0, as: Int.self]
        }

        static func replace(_ spaceId: UInt32, _ tuple: [UInt8]) throws {
            let pointer = try copyToInternalMemory(tuple)
            guard box_replace(
                spaceId, pointer, pointer+tuple.count, nil) == 0 else {
                    throw Error()
            }
        }

        static func update(
            _ spaceId: UInt32,
            _ indexId: UInt32,
            _ keys: [UInt8],
            _ ops: [UInt8]
        ) throws {
            let pKeys = try copyToInternalMemory(keys)
            let pOps = try copyToInternalMemory(ops)
            guard box_update(
                spaceId,
                indexId,
                pKeys,
                pKeys+keys.count,
                pOps,
                pOps+ops.count,
                0,
                nil) == 0
            else {
                throw Error()
            }
        }

        static func upsert(
            _ spaceId: UInt32,
            _ indexId: UInt32,
            _ tuple: [UInt8],
            _ ops: [UInt8]
        ) throws {
            let pTuple = try copyToInternalMemory(tuple)
            let pOps = try copyToInternalMemory(ops)
            guard box_upsert(
                spaceId,
                indexId,
                pTuple,
                pTuple+tuple.count,
                pOps,
                pOps+ops.count,
                0,
                nil) == 0
            else {
                throw Error()
            }
        }

        static func delete(
            _ spaceId: UInt32, _ indexId: UInt32, _ keys: [UInt8]
        ) throws{
            let pointer = UnsafePointer<CChar>(keys)
            guard box_delete(
                spaceId, indexId, pointer, pointer+keys.count, nil) == 0 else {
                    throw Error()
            }
        }
    }
}

extension Box.API {
    private static let invalid = UInt32(Int32.max)

    static func getSpaceIdByName(_ name: [UInt8]) throws -> UInt32 {
        let pointer = UnsafePointer<CChar>(name)
        let id = box_space_id_by_name(pointer, UInt32(name.count))
        if id == invalid {
            throw Tarantool.Error.spaceNotFound
        }
        return id
    }

    static func getIndexIdByName(
        _ name: [UInt8], spaceId: UInt32
    ) throws -> UInt32 {
        let pointer = UnsafePointer<CChar>(name)
        let id = box_index_id_by_name(spaceId, pointer, UInt32(name.count))
        if id == invalid {
            throw Tarantool.Error.indexNotFound
        }
        return id
    }

    // will be deallocated after transaction is finished.
    // every insert, update, etc is a single statement transaction.
    static func copyToInternalMemory(
        _ bytes: [UInt8]
    ) throws -> UnsafePointer<CChar> {
        guard let buffer = box_txn_alloc(bytes.count) else {
            throw Tarantool.Error.notEnoughMemory
        }
        memcpy(buffer, bytes, bytes.count)
        return UnsafeRawPointer(buffer).assumingMemoryBound(to: CChar.self)
    }
}

extension UnsafePointer where Pointee == CChar {
    @inline(__always)
    init(_ bytes: [UInt8]) {
        self = UnsafeRawPointer(bytes).assumingMemoryBound(to: CChar.self)
    }
}
