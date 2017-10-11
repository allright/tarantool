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
import MessagePack

extension String: Error {}

extension Array where Element == MessagePack {
    init<T: Tarantool.Tuple>(_ tuple: T) {
        var result = [MessagePack]()
        for i in 0..<tuple.count {
            result.append(tuple[i]!)
        }
        self = result
    }
}

extension Array where Element == [MessagePack] {
    init<T: Tarantool.Tuple>(_ tuples: AnySequence<T>) {
        var result = [[MessagePack]]()
        for tuple in tuples {
            result.append([MessagePack](tuple))
        }
        self = result
    }
}

func ==(lhs: [[MessagePack]], rhs: [[MessagePack]]) -> Bool {
    return lhs.elementsEqual(rhs, by: { $0.elementsEqual($1) })
}
