extension Tarantool {
    public enum Error: Swift.Error {
        case spaceNotFound
        case indexNotFound
        case invalidSchema
        case invalidEngine
        case invalidIndex(message: String)
        case invalidTuple(message: String)
        case notEnoughMemory
        case unexpected(message: String)
    }
}
