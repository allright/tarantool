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

extension IProto {
    public struct Tuple: Tarantool.Tuple {
        var tuple: [MessagePack]

        public init(_ tuple: [MessagePack]) {
            self.tuple = tuple
        }

        public var startIndex: Int {
            return tuple.startIndex
        }

        public var endIndex: Int {
            return tuple.endIndex
        }

        public subscript(index: Int) -> MessagePack? {
            return tuple[index]
        }
    }
}

extension IProto.Tuple {
    public func unpack() -> [MessagePack] {
        return tuple
    }
}

extension IProto.Tuple: Equatable {
    public static func ==(lhs: IProto.Tuple, rhs: IProto.Tuple) -> Bool {
        return lhs.tuple == rhs.tuple
    }
}
