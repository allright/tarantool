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
import CTarantool

import struct Dispatch.DispatchQoS
import class Dispatch.DispatchQueue

@inline(__always)
public func fiber(_ closure: @escaping () -> Void) {
    var closure = closure
    fiber_wrapper(&closure, { pointer in
        pointer?.assumingMemoryBound(to: (() -> Void).self).pointee()
    })
}

@inline(__always)
public func syncTask<T>(
    onQueue queue: DispatchQueue = DispatchQueue.global(),
    qos: DispatchQoS = .background,
    deadline: Time = .distantFuture,
    task: @escaping () throws -> T
) throws -> T {
    return try COIO.syncTask(
        qos: qos,
        deadline: deadline,
        task: task)
}

@inline(__always)
public func yield() {
    _fiber_reschedule()
}

@inline(__always)
public func sleep(until deadline: Time) {
    _fiber_sleep(Double(deadline.timeIntervalSinceNow))
}

@inline(__always)
public func now() -> Time {
    let time = _fiber_time()
    return Time(seconds: Int(time), nanoseconds: 0)
}

@inline(__always)
public func transaction<T>(
    _ closure: () throws -> T
) throws -> T {
    return try Box.transaction(closure)
}
