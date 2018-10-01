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

import Stream
import MessagePack
import CTarantool

extension Box {
    public typealias Context = OpaquePointer
    public typealias Result = Int32

    public struct Output {
        let context: Context

        public func append(_ tuple: Tuple) throws {
            guard Box.returnTuple(tuple, to: context) == 0 else {
                throw Box.Error()
            }
        }

        public func append(_ tuple: [MessagePack]) throws {
            guard Box.returnTuple(tuple, to: context) == 0 else {
                throw Box.Error()
            }
        }
    }

    @inline(__always)
    public // @testable
    static func execute(_ task: () throws -> Void) -> Result {
        do {
            try task()
            return 0
        } catch let error as Box.Error {
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
        _ tuple: Tuple, to context: Context
    ) -> Result {
        return box_return_tuple(context, tuple.pointer)
    }

    public static func returnTuple(
        _ tuple: [MessagePack], to context: Context
    ) -> Result {
        let stream = OutputByteStream()
        var writer = MessagePackWriter(stream)
        do {
            try writer.encode(tuple)
        } catch {
            return returnError(
                code: .invalidMsgpack,
                message: "encoding of \(tuple) failed")
        }

        let bytes = stream.bytes
        let pointer = UnsafeRawPointer(bytes).assumingMemoryBound(to: Int8.self)
        let tuple = box_tuple_new(
            box_tuple_format_default(), pointer, pointer+bytes.count)
        return box_return_tuple(context, tuple)
    }

    public static func returnError(
        code: Box.Error.Code,
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
