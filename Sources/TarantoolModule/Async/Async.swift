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

@_exported import Async

import Time
import Platform
import CTarantool

import struct Dispatch.DispatchQoS
import class Dispatch.DispatchQueue

public struct AsyncTarantool: Async {
    public init() {}

    public var loop: AsyncLoop = TarantoolLoop()

    public func task(_ closure: @escaping AsyncTask) -> Void {
        fiber(closure)
    }

    /// doesn't support fibers inside the task
    public func syncTask<T>(
        onQueue queue: DispatchQueue = DispatchQueue.global(),
        qos: DispatchQoS = .background,
        deadline: Time = .distantFuture,
        task: @escaping () throws -> T
    ) throws -> T {
        return try COIO.syncTask(
            onQueue: queue, qos: qos, deadline: deadline, task: task)
    }

    public func wait(
        for descriptor: Descriptor,
        event: IOEvent,
        deadline: Time = .distantFuture
    ) throws {
        try COIO.wait(for: descriptor, event: event, deadline: deadline)
    }

    public func sleep(until deadline: Time) {
        _fiber_sleep(Double(deadline.timeIntervalSinceNow))
    }

    public func testCancel() throws {
        if _fiber_is_cancelled() {
            throw AsyncError.taskCanceled
        }
    }
}

public struct TarantoolLoop: AsyncLoop {
    public func run() {
        // fallback to tarantool's built-in event loop
    }

    public func run(until date: Time) {
        fatalError("not implemented")
    }

    public func terminate() {
        fatalError("not implemented")
    }
}
