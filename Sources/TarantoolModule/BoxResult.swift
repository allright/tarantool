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
import MessagePack

public typealias BoxResult = Int32
public typealias BoxContext = OpaquePointer

extension Box {
    public static func returnTuple(
        _ bytes: [UInt8], to context: BoxContext
    ) -> Int32 {
        let pointer = UnsafeRawPointer(bytes).assumingMemoryBound(to: Int8.self)
        let tuple = _box_tuple_new(
            _box_tuple_format_default(), pointer, pointer+bytes.count)
        return _box_return_tuple(context, tuple)
    }

    public static func returnTuple(
        _ object: MessagePack, to context: BoxContext
    ) -> Int32 {
        return returnTuple(MessagePack.encode(object), to: context)
    }

    public static func returnError(
        code: BoxError.Code,
        message: String,
        file: String = #file,
        line: Int = #line
    ) -> BoxResult {
        return box_error_set_wrapper(file, UInt32(line), code.rawValue, message)
    }
}
