/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

fileprivate let _vspace: Int = 281

public struct Schema<T: DataSource> {
    public let spaces: [String: Space<T>]
    public init(_ source: T) throws {
        let sysview = Space(id: _vspace, source: source)
        let tuples = try sysview.select(.all)

        var spaces: [String: Space<T>] = [:]
        for tuple in tuples {
            guard let id = Int(tuple[0]),
                let name = String(tuple[2]) else {
                    throw TarantoolError.invalidSchema
            }
            spaces[name] = Space(id: id, source: source)
        }
        self.spaces = spaces
    }
}
