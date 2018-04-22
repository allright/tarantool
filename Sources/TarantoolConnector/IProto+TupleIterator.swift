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

extension IProto {
    struct TupleIterator: IteratorProtocol {
        let tuples: [MessagePack]
        var index: Int

        init(tuples: [MessagePack]) {
            self.tuples = tuples
            self.index = 0
        }

        mutating func next() -> Tuple? {
            guard index < tuples.count else {
                return nil
            }
            guard let tuple = tuples[index].arrayValue else {
                return nil
            }
            index += 1
            return Tuple(tuple)
        }
    }
}
