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

    public init(code: Code, message: String) {
        self.code = code
        self.message = message
    }

    init() {
        guard let error = _box_error_last() else {
            self.code = .unknown
            self.message = "success"
            return
        }

        guard let code = Code(rawValue: _box_error_code(error)),
            let message = _box_error_message(error) else {
                self.code = .unknown
                self.message = "error"
                return
        }

        self.code = code
        self.message = String(cString: message)
    }
}

extension BoxError: CustomStringConvertible {
    public var description: String {
        return "code: \(code) message: \(message)"
    }
}
