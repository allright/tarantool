import Stream
import CTarantool
import MessagePack

extension Box {
    public struct Tuple: Tarantool.Tuple {
        let pointer: OpaquePointer

        public // @testable
        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }

        var size: Int {
            return box_tuple_bsize(pointer)
        }

        public var startIndex: Int {
            return 0
        }

        public var endIndex: Int {
            return Int(box_tuple_field_count(pointer))
        }

        public func index(before i: Int) -> Int {
            precondition(i > startIndex)
            return i - 1
        }

        public func index(after i: Int) -> Int {
            precondition(i < endIndex)
            return i + 1
        }

        @inline(__always)
        func getFieldMaxSize(_ field: UnsafePointer<Int8>) -> Int {
            return size - (UnsafePointer<Int8>(pointer) - field)
        }

        public subscript(index: Int) -> MessagePack? {
            guard let field =
                box_tuple_field(pointer, numericCast(index)) else {
                    return nil
            }
            var decoder = MessagePackReader(UnsafeRawInputStream(
                pointer: field, count: getFieldMaxSize(field)))
            return try? decoder.decode()
        }
    }
}

extension Box.Tuple {
    public func unpack() -> [MessagePack] {
        let size = self.size
        guard size > 0 else {
            return []
        }

        let iterator = box_tuple_iterator(pointer)!
        defer { box_tuple_iterator_free(iterator) }

        var tuple = [MessagePack]()

        if let first = box_tuple_next(iterator) {
            let tupleEnd = first + size
            first.withMemoryRebound(to: UInt8.self, capacity: size) { pointer in
                var decoder = MessagePackReader(
                    UnsafeRawInputStream(pointer: pointer, count: size))
                tuple.append(try! decoder.decode())
            }

            var fieldSize = size
            while let next = box_tuple_next(iterator) {
                fieldSize = tupleEnd - next
                next.withMemoryRebound(
                    to: UInt8.self, capacity: fieldSize
                ) { pointer in
                    var decoder = MessagePackReader(
                        UnsafeRawInputStream(pointer: pointer, count: size))
                    tuple.append(try! decoder.decode())
                }
            }
        }

        return tuple
    }
}

extension Box.Tuple {
    public subscript(index: Int, as type: Bool.Type) -> Bool? {
        guard let field = box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = MessagePackReader(
            UnsafeRawInputStream(pointer: field, count: getFieldMaxSize(field)))
        return try? decoder.decode(Bool.self)
    }

    public subscript(index: Int, as type: Int.Type) -> Int? {
        guard let field = box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = MessagePackReader(
            UnsafeRawInputStream(pointer: field, count: getFieldMaxSize(field)))
        return try? decoder.decode(Int.self)
    }

    public subscript(index: Int, as type: UInt.Type) -> UInt? {
        guard let field = box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = MessagePackReader(
            UnsafeRawInputStream(pointer: field, count: getFieldMaxSize(field)))
        return try? decoder.decode(UInt.self)
    }

    public subscript(index: Int, as type: Float.Type) -> Float? {
        guard let field = box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = MessagePackReader(
            UnsafeRawInputStream(pointer: field, count: getFieldMaxSize(field)))
        return try? decoder.decode(Float.self)
    }

    public subscript(index: Int, as type: Double.Type) -> Double? {
        guard let field = box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = MessagePackReader(
            UnsafeRawInputStream(pointer: field, count: getFieldMaxSize(field)))
        return try? decoder.decode(Double.self)
    }

    public subscript(index: Int, as type: String.Type) -> String? {
        guard let field = box_tuple_field(pointer, numericCast(index)) else {
            return nil
        }
        var decoder = MessagePackReader(
            UnsafeRawInputStream(pointer: field, count: getFieldMaxSize(field)))
        return try? decoder.decode(String.self)
    }
}
