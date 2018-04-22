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

import Time
import Async
import Platform
import CTarantool

public struct COIO {
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
        for descriptor: Descriptor,
        event: IOEvent,
        deadline: Time = .distantFuture
    ) throws {
        let timeout = deadline == .distantFuture
            ? Timeout.infinity
            : Double(deadline.timeIntervalSinceNow)

        let event = Event(event)
        let result = _coio_wait(descriptor.rawValue, event.rawValue, timeout)
        guard let receivedEvent = Event(rawValue: result) else {
            throw AsyncError.taskCanceled
        }
        guard receivedEvent == event else {
            throw AsyncError.timeout
        }
    }
}
