/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Async
import CTarantool

import struct Foundation.Date

public struct COIOWrapper {
    struct Timeout {
        static let infinity: Double = 100*365*24*3600
    }

    enum Event: Int32 {
        case read = 0x1
        case write = 0x2

        init(_ event: IOEvent) {
            switch event {
            case .read: self = .read
            case .write: self = .write
            }
        }
    }

    public static func wait(
        for descriptor: Int32,
        event: IOEvent,
        deadline: Date = Date.distantFuture
    ) throws {
        let timeout = deadline == Date.distantFuture
            ? Timeout.infinity
            : deadline.timeIntervalSinceNow

        let event = Event(event)
        let result = _coio_wait(descriptor, event.rawValue, timeout)
        guard let receivedEvent = Event(rawValue: result) else {
            throw AsyncError.taskCanceled
        }
        guard receivedEvent == event else {
            throw AsyncError.timeout
        }
    }
}
