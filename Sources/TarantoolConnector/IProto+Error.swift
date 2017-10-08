/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

extension IProto {
    public enum Error: Swift.Error {
        case invalidWelcome(reason: PacketError)
        case invalidSalt
        case invalidPacket(reason: PacketError)
        case badRequest(code: Int, message: String)
        case streamWriteFailed
    }

    public enum PacketError {
        case invalidSize
        case invalidHeader
        case invalidCode
        case invalidBodyHeader
        case invalidBody
    }
}
