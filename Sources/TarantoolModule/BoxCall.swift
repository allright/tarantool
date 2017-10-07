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
    public static func convertCall(
        _ context: BoxContext,
        _ task: () throws -> [MessagePack]
    ) -> BoxResult {
        do {
            let result = try task()
            return Box.returnTuple(result, to: context)
        } catch let error as BoxError {
            return Box.returnError(code: error.code, message: error.message)
        } catch {
            let message = String(describing: error)
            return Box.returnError(code: .procC, message: message)
        }
    }

    public static func convertCall(
        _ context: BoxContext,
        _ arguments: UnsafeRawPointer,
        _ argumentsEnd: UnsafeRawPointer,
        _ task: ([MessagePack]) throws -> [MessagePack]
    ) -> BoxResult {
        return convertCall(context) {
            let arguments = try [MessagePack](arguments, argumentsEnd)
            return try task(arguments)
        }
    }

    public static func returnTuple(
        _ bytes: [UInt8], to context: BoxContext
    ) -> Int32 {
        let pointer = UnsafeRawPointer(bytes).assumingMemoryBound(to: Int8.self)
        let tuple = _box_tuple_new(
            _box_tuple_format_default(), pointer, pointer+bytes.count)
        return _box_return_tuple(context, tuple)
    }

    public static func returnTuple(
        _ tuple: [MessagePack], to context: BoxContext
    ) -> Int32 {
        var writer = MessagePackWriter(OutputByteStream())
        do {
            try writer.encode(tuple)
        } catch {
            return returnError(
                code: .invalidMsgpack,
                message: "encoding of \(tuple) failed")
        }
        return returnTuple(writer.stream.bytes, to: context)
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

extension Array where Element == MessagePack {
    init(_ start: UnsafeRawPointer, _ end: UnsafeRawPointer) throws {
        var reader = MessagePackReader(InputRawStream(
            pointer: start, count: end - start))
        self = try reader.decode([MessagePack].self)
    }
}
