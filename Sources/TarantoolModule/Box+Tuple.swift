/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Tarantool
import CTarantool
import MessagePack

extension Box {
    static func unpackTuple(_ tuple: OpaquePointer) throws -> Tuple {
        let tupleSize = _box_tuple_bsize(tuple)
        guard tupleSize > 0 else {
            throw TarantoolError.invalidTuple(message: "tuple size: \(tupleSize)")
        }

        guard let iterator = _box_tuple_iterator(tuple) else {
            throw TarantoolError.invalidTuple(message: "can't create iterator")
        }
        defer { _box_tuple_iterator_free(iterator) }

        var tuple = Tuple()

        guard let first = _box_tuple_next(iterator) else {
            return tuple
        }

        let tupleEnd = first + tupleSize
        try first.withMemoryRebound(to: UInt8.self, capacity: tupleSize) { pointer in
            let field = try MessagePack.decode(bytes: pointer, count: tupleSize)
            tuple.append(field)
        }

        var fieldSize = tupleSize
        while let next = _box_tuple_next(iterator) {
            fieldSize = tupleEnd - next
            try next.withMemoryRebound(to: UInt8.self, capacity: fieldSize) { pointer in
                let field = try MessagePack.decode(bytes: pointer, count: fieldSize)
                tuple.append(field)
            }
        }

        return tuple
    }
}
