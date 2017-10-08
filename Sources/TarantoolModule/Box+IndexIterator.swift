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
import MessagePack

extension Box {
    class IndexIterator: IteratorProtocol {
        let iterator: OpaquePointer

        init(_ iterator: OpaquePointer) {
            self.iterator = iterator
        }

        deinit {
            _box_iterator_free(iterator)
        }

        func next() -> BoxTuple? {
            var result: OpaquePointer?
            guard _box_iterator_next(iterator, &result) == 0,
                let pointer = result else {
                    return nil
            }
            return BoxTuple(pointer)
        }
    }
}
