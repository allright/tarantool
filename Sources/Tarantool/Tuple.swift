/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import MessagePack

public protocol Tuple
: RandomAccessCollection, RawRepresentable, CustomStringConvertible {
    init()
    var rawValue: [MessagePack] { get }
    subscript(index: Int) -> MessagePack? { get }
}

extension Tuple {
    public var description: String {
        return rawValue.description
    }
}

public typealias Map = [MessagePack : MessagePack]
