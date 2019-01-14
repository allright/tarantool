extension IProto {
    struct TupleIterator: IteratorProtocol {
        let tuples: [MessagePack]
        var index: Int

        init(tuples: [MessagePack]) {
            self.tuples = tuples
            self.index = 0
        }

        mutating func next() -> Tuple? {
            guard index < tuples.count else {
                return nil
            }
            guard let tuple = tuples[index].arrayValue else {
                return nil
            }
            index += 1
            return Tuple(tuple)
        }
    }
}
