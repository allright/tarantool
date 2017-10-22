/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import CTarantool

extension Box {
    class IndexIterator: IteratorProtocol {
        let iterator: OpaquePointer

        init?(_ spaceId: UInt32,
              _ indexId: UInt32,
              _ iterator: Int32,
              _ keys: UnsafePointer<CChar>,
              _ keysEnd: UnsafePointer<CChar>)
        {
            guard let iterator = _box_index_iterator(
                spaceId, indexId, iterator, keys, keysEnd) else {
                    return nil
            }
            self.iterator = iterator
        }

        deinit {
            _box_iterator_free(iterator)
        }

        func next() -> Tuple? {
            var result: OpaquePointer?
            guard _box_iterator_next(iterator, &result) == 0,
                let pointer = result else {
                    return nil
            }
            return Tuple(pointer)
        }
    }
}
