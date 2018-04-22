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
import Network
import Foundation

@_exported import Tarantool
@_exported import MessagePack

public class IProto {
    let welcome: Welcome
    var inputStream: BufferedInputStream<NetworkStream>
    var outputStream: BufferedOutputStream<NetworkStream>

    public init(host: String, port: Int = 3301, bufferSize: Int = 4096) throws {
        let socket = try Socket().connect(to: host, port: port)
        let networkStream = NetworkStream(socket: socket)
        inputStream = BufferedInputStream(
            baseStream: networkStream,
            capacity: bufferSize)
        outputStream = BufferedOutputStream(
            baseStream: networkStream,
            capacity: bufferSize)
        welcome = try Welcome(from: &inputStream)
    }

    public typealias Code = Message.Code
    public typealias Key = Message.Key

    public func request(
        code: Code,
        keys: [Key : MessagePack] = [:],
        sync: Int? = nil,
        schemaId: Int? = nil
    ) throws -> [MessagePack] {
        let request = Message(
            code: code,
            sync: sync,
            schemaId: schemaId,
            body: keys
        )

        try request.encode(to: outputStream)
        try outputStream.flush()

        let response = try Message(from: inputStream)

        return response.body[Message.Key.data]?.arrayValue ?? []
    }
}

extension IProto {
    public func ping() throws {
        _ = try request(code: .ping)
    }

    public func auth(username: String, password: String) throws {
        let data = [UInt8](password.utf8)
        guard let salt = Data(base64Encoded: welcome.salt) else {
            throw IProto.Error.invalidSalt
        }

        let scramble = data.chapSha1(salt: [UInt8](salt))

        let keys: [Key : MessagePack] = [
            .username: .string(username),
            .tuple: .array([
                .string("chap-sha1"),
                .binary(scramble)
            ])
        ]
        _ = try request(code: .auth, keys: keys)
    }
}
