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

extension Array where Element == [MessagePack] {
    init<T: Tuple>(_ tuples: AnySequence<T>) {
        var result = [[MessagePack]]()
        for tuple in tuples {
            result.append(tuple.unpack())
        }
        self = result
    }
}

func ==(lhs: [[MessagePack]], rhs: [[MessagePack]]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for i in 0..<lhs.endIndex {
        if lhs[i] != rhs[i] {
            return false
        }
    }
    return true
}
