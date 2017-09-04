/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

@_exported import Async

import Platform
import CTarantool
import TarantoolModule

import struct Foundation.Date
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
        deadline: Date = Date.distantFuture,
        task: @escaping () throws -> T
    ) throws -> T {
        return try DispatchWrapper.syncTask(
            onQueue: queue, qos: qos, deadline: deadline, task: task)
    }

    public func wait(
        for descriptor: Int32,
        event: IOEvent,
        deadline: Date = Date.distantFuture
    ) throws {
        try COIOWrapper.wait(for: descriptor, event: event, deadline: deadline)
    }

    public func sleep(until deadline: Date) {
        _fiber_sleep(deadline.timeIntervalSinceNow)
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

    public func run(until date: Date) {
        fiber {
            sleep(until: date)
            exit(0)
        }
    }
}
