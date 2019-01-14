extension IProto {
    public enum Error: Swift.Error {
        case invalidWelcome(reason: PacketError)
        case invalidSalt
        case invalidPacket(reason: PacketError)
        case badRequest(code: Int, message: String)
    }

    public enum PacketError {
        case invalidSize
        case invalidHeader
        case invalidCode
        case invalidBodyHeader
        case invalidBody
    }
}
