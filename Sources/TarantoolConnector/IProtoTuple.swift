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

public struct IProtoTuple: Tuple {
    var tuple: [MessagePack]

    public init() {
        tuple = []
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

extension IProtoTuple: RawRepresentable {
    public init(rawValue: [MessagePack]) {
        self.tuple = rawValue
    }

    public var rawValue: [MessagePack] {
        return self.tuple
    }
}

extension IProtoTuple: Equatable {
    public static func ==(lhs: IProtoTuple, rhs: IProtoTuple) -> Bool {
        return lhs.tuple == rhs.tuple
    }
}
