/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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
