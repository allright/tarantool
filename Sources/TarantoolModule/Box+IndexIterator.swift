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

extension Box {
    class IndexIterator: IteratorProtocol {
        let iterator: OpaquePointer
        var offset: Int
        var limit: Int

        init?(_ spaceId: UInt32,
              _ indexId: UInt32,
              _ iterator: Int32,
              _ keys: UnsafePointer<CChar>,
              _ keysEnd: UnsafePointer<CChar>,
              _ offset: Int,
              _ limit: Int)
        {
            guard let iterator = _box_index_iterator(
                spaceId, indexId, iterator, keys, keysEnd) else {
                    return nil
            }
            self.iterator = iterator
            self.offset = offset
            self.limit = limit
        }

        deinit {
            _box_iterator_free(iterator)
        }

        func next() -> Tuple? {
            guard limit > 0 else {
                return nil
            }
            if offset > 0 {
                guard skip(&offset) else {
                    return nil
                }
            }
            var result: OpaquePointer?
            guard _box_iterator_next(iterator, &result) == 0,
                let pointer = result else {
                    return nil
            }
            limit -= 1
            return Tuple(pointer)
        }

        func skip(_ count: inout Int) -> Bool {
            var result: OpaquePointer?
            while count > 0 {
                count -= 1
                guard _box_iterator_next(iterator, &result) == 0 else {
                    return false
                }
            }
            return true
        }
    }
}
