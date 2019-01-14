import MessagePack

public struct Tarantool {
    public typealias Tuple = TupleProtocol
}

public protocol TupleProtocol: RandomAccessCollection {
    var count: Int { get }
    subscript(index: Int) -> MessagePack? { get }
}
