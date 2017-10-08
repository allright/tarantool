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
import Stream
import MessagePack

public struct Output {
    let context: OpaquePointer

    public func append(_ tuple: BoxTuple) throws {
        guard Box.returnTuple(tuple, to: context) == 0 else {
            throw BoxError()
        }
    }

    public func append(_ tuple: [MessagePack]) throws {
        guard Box.returnTuple(tuple, to: context) == 0 else {
            throw BoxError()
        }
    }
}

extension Box {
    public typealias Context = OpaquePointer
    public typealias Result = Int32

    @inline(__always)
    public // @testable
    static func execute(_ task: () throws -> Void) -> Result {
        do {
            try task()
            return 0
        } catch let error as BoxError {
            return Box.returnError(code: error.code, message: error.message)
        } catch {
            let message = String(describing: error)
            return Box.returnError(code: .procC, message: message)
        }
    }

    public static func convertCall(
        _ context: Context,
        _ task: (Output) throws -> Void
    ) -> Result {
        return execute {
            try task(Output(context: context))
        }
    }

    public static func convertCall(
        _ context: Context,
        _ arguments: UnsafeRawPointer,
        _ argumentsEnd: UnsafeRawPointer,
        _ task: ([MessagePack], Output) throws -> Void
    ) -> Result {
        return execute {
            let arguments = try [MessagePack](arguments, argumentsEnd)
            try task(arguments, Output(context: context))
        }
    }

    public static func returnTuple(
        _ tuple: BoxTuple, to context: Context
    ) -> Result {
        return _box_return_tuple(context, tuple.pointer)
    }

    public static func returnTuple(
        _ tuple: [MessagePack], to context: Context
    ) -> Result {
        var writer = MessagePackWriter(OutputByteStream())
        do {
            try writer.encode(tuple)
        } catch {
            return returnError(
                code: .invalidMsgpack,
                message: "encoding of \(tuple) failed")
        }

        let bytes = writer.stream.bytes
        let pointer = UnsafeRawPointer(bytes).assumingMemoryBound(to: Int8.self)
        let tuple = _box_tuple_new(
            _box_tuple_format_default(), pointer, pointer+bytes.count)
        return _box_return_tuple(context, tuple)
    }

    public static func returnError(
        code: BoxError.Code,
        message: String,
        file: String = #file,
        line: Int = #line
    ) -> Result {
        return box_error_set_wrapper(file, UInt32(line), code.rawValue, message)
    }
}

extension Array where Element == MessagePack {
    init(_ start: UnsafeRawPointer, _ end: UnsafeRawPointer) throws {
        var reader = MessagePackReader(UnsafeRawInputStream(
            pointer: start, count: end - start))
        self = try reader.decode([MessagePack].self)
    }
}
