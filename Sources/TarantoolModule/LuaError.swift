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

public struct LuaError: Error {
    public let code: Int?
    public let message: String
}

extension LuaError {
    public init(message: String) {
        self.code = nil
        self.message = message
    }
}

extension LuaError {
    init(_ L: OpaquePointer) {
        // standart lua error
        if let pointer = _lua_tolstring(L, -1, nil) {
            self.code = nil
            self.message = String(cString: pointer)
            return
        }

        // tarantool error
        if let errorPointer = _box_error_last(),
            let messagePointer = _box_error_message(errorPointer) {
            self.code = Int(_box_error_code(errorPointer))
            self.message = String(cString: messagePointer)
            return
        }

        self.code = nil
        self.message = "unknown"
    }
}
