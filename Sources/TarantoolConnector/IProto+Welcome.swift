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

private let headerSize = 64
private let saltSize = 44
private let size = 128

extension IProto {
    struct Welcome {
        var header: String
        var salt: String

        static var packetSize: Int {
            return size
        }

        init<T: StreamReader>(from stream: inout T) throws {
            var buffer = try stream.read(count: Welcome.packetSize)
            self.header = String(slice: buffer.prefix(upTo: headerSize))
            self.salt = String(slice: buffer[headerSize..<headerSize+saltSize])

            guard header.hasPrefix("Tarantool") else {
                throw IProto.Error.invalidWelcome(reason: .invalidHeader)
            }
        }
    }
}

private extension String {
    init(slice: ArraySlice<UInt8>) {
        self = String(cString: Array(slice) + [0])
    }
}
