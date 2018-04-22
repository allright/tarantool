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
