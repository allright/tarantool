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

public struct BoxError: Error {
    public let code: Code
    public let message: String

    init(){
        guard let errorPointer = _box_error_last() else {
            self.code = .unknown
            self.message = "success"
            return
        }
        let errorCode = _box_error_code(errorPointer)
        let errorMessage = _box_error_message(errorPointer)

        self.code = Code(rawValue: errorCode) ?? .unknown
        self.message = errorMessage != nil ? String(cString: errorMessage!) : "nil"
    }
}

extension BoxError: CustomStringConvertible {
    public var description: String {
        return "code: \(code) message: \(message)"
    }
}
