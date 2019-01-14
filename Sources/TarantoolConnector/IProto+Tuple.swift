import Tarantool
import MessagePack

extension IProto {
    public struct Tuple: Tarantool.Tuple {
        var tuple: [MessagePack]

        public init(_ tuple: [MessagePack]) {
            self.tuple = tuple
        }

        public var startIndex: Int {
            return tuple.startIndex
        }

        public var endIndex: Int {
            return tuple.endIndex
        }

        public func index(before i: Int) -> Int {
            return tuple.index(before: i)
        }

        public func index(after i: Int) -> Int {
            return tuple.index(after: i)
        }

        public subscript(index: Int) -> MessagePack? {
            return tuple[index]
        }
    }
}

extension IProto.Tuple {
    public func unpack() -> [MessagePack] {
        return tuple
    }
}

extension IProto.Tuple: Equatable {
    public static func ==(lhs: IProto.Tuple, rhs: IProto.Tuple) -> Bool {
        return lhs.tuple == rhs.tuple
    }
}
