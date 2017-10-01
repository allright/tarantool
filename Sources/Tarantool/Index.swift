/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

public enum IndexType: String {
    case hash
    case tree
    case bitset
    case rtree
}

public enum IndexFieldType: String {
    case unsigned
    case integer
    case string
    case array
}

public struct Index {
    let id: Int
    let name: String
    let type: IndexType
    let sequenceId: Int?
    let unique: Bool

    var sequence: Bool {
        return sequenceId != nil
    }

    public init(
        id: Int,
        name: String,
        type: IndexType,
        sequenceId: Int? = nil,
        unique: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.sequenceId = sequenceId
        self.unique = unique
    }
}

extension Index: Equatable {
    public static func ==(lhs: Index, rhs: Index) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.sequenceId == rhs.sequenceId &&
            lhs.unique == rhs.unique
    }
}
