/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

import CTarantool

extension Lua {
    public struct Error: Swift.Error {
        public let code: Int?
        public let message: String
    }
}

extension Lua.Error {
    public init(message: String) {
        self.code = nil
        self.message = message
    }
}

extension Lua.Error {
    init(_ L: OpaquePointer) {
        // standart lua error
        if let pointer = lua_tolstring(L, -1, nil) {
            self.code = nil
            self.message = String(cString: pointer)
            return
        }

        // tarantool error
        if let errorPointer = box_error_last(),
            let messagePointer = box_error_message(errorPointer) {
            self.code = Int(box_error_code(errorPointer))
            self.message = String(cString: messagePointer)
            return
        }

        self.code = nil
        self.message = "unknown"
    }
}

extension Lua.Error: CustomStringConvertible {
    public var description: String {
        guard let code = code else {
            return message
        }
        return "\(code): \(message)"
    }
}
