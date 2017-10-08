/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import CTarantool

import struct Foundation.Date
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
    deadline: Date = Date.distantFuture,
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
public func sleep(until deadline: Date) {
    _fiber_sleep(deadline.timeIntervalSinceNow)
}

@inline(__always)
public func now() -> Date {
    return Date(timeIntervalSince1970: _fiber_time())
}

@inline(__always)
public func transaction<T>(
    _ closure: () throws -> T
) throws -> T {
    return try Box.transaction(closure)
}
