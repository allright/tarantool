import Base64
import Stream
import Network
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
        let bytes = [UInt8](password.utf8)
        guard let salt = [UInt8](decodingBase64: welcome.salt) else {
            throw IProto.Error.invalidSalt
        }
        let scramble = bytes.chapSha1(salt: salt)
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
