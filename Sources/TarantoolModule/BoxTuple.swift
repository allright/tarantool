/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Tarantool
import CTarantool
import MessagePack

public final class BoxTuple: Tuple {
    let pointer: OpaquePointer

    public convenience init() {
        self.init(rawValue: [])!
    }

    // FIXME: should be internal, but needed for TarantoolModuleTest
    // currently we can't build the module in release mode using @testable
    public init?(_ pointer: OpaquePointer) {
        self.pointer = pointer
        guard _box_tuple_ref(pointer) == 0 else {
            return nil
        }
    }

    deinit {
        _box_tuple_unref(pointer)
    }

    var size: Int {
        return _box_tuple_bsize(pointer)
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return Int(_box_tuple_field_count(pointer))
    }

    @inline(__always)
    func getFieldMaxSize(_ field: UnsafePointer<Int8>) -> Int {
        return size - (UnsafePointer<Int8>(pointer) - field)
    }

    public subscript(index: Int) -> MessagePack? {
        guard let field = _box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = UnsafeMessagePackDecoder(
            bytes: field, count: getFieldMaxSize(field))
        return try? decoder.decode()
    }
}

extension BoxTuple: RawRepresentable {
    public convenience init?(rawValue: [MessagePack]) {
        var encoder = MessagePackEncoder()
        encoder.encode(rawValue)
        let bytes = encoder.bytes
        let pointer = UnsafeRawPointer(bytes).assumingMemoryBound(to: Int8.self)
        let format = _box_tuple_format_default()
        guard let tuple =
            _box_tuple_new(format, pointer, pointer+bytes.count) else {
                return nil
        }
        self.init(tuple)
    }

    public var rawValue: [MessagePack] {
        let size = self.size
        guard size > 0 else {
            return []
        }

        let iterator = _box_tuple_iterator(pointer)!
        defer { _box_tuple_iterator_free(iterator) }

        var tuple = [MessagePack]()

        if let first = _box_tuple_next(iterator) {
            let tupleEnd = first + size
            first.withMemoryRebound(to: UInt8.self, capacity: size) { pointer in
                let field = try! MessagePack.decode(bytes: pointer, count: size)
                tuple.append(field)
            }

            var fieldSize = size
            while let next = _box_tuple_next(iterator) {
                fieldSize = tupleEnd - next
                next.withMemoryRebound(
                    to: UInt8.self, capacity: fieldSize
                ) { pointer in
                    let field = try! MessagePack.decode(
                        bytes: pointer, count: fieldSize)
                    tuple.append(field)
                }
            }
        }

        return tuple
    }
}

extension BoxTuple {
    public subscript(index: Int, as type: Bool.Type) -> Bool? {
        guard let field = _box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = UnsafeMessagePackDecoder(
            bytes: field, count: getFieldMaxSize(field))
        return try? decoder.decode(Bool.self)
    }

    public subscript(index: Int, as type: Int.Type) -> Int? {
        guard let field = _box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = UnsafeMessagePackDecoder(
            bytes: field, count: getFieldMaxSize(field))
        return try? decoder.decode(Int.self)
    }

    public subscript(index: Int, as type: UInt.Type) -> UInt? {
        guard let field = _box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = UnsafeMessagePackDecoder(
            bytes: field, count: getFieldMaxSize(field))
        return try? decoder.decode(UInt.self)
    }

    public subscript(index: Int, as type: Float.Type) -> Float? {
        guard let field = _box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = UnsafeMessagePackDecoder(
            bytes: field, count: getFieldMaxSize(field))
        return try? decoder.decode(Float.self)
    }

    public subscript(index: Int, as type: Double.Type) -> Double? {
        guard let field = _box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = UnsafeMessagePackDecoder(
            bytes: field, count: getFieldMaxSize(field))
        return try? decoder.decode(Double.self)
    }

    public subscript(index: Int, as type: String.Type) -> String? {
        guard let field = _box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = UnsafeMessagePackDecoder(
            bytes: field, count: getFieldMaxSize(field))
        return try? decoder.decode(String.self)
    }
}
