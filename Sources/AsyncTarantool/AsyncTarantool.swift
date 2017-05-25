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
import Foundation
import TarantoolModule

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

public struct AsyncTarantool: Async {
    public init() {}
    public var loop: AsyncLoop = TarantoolLoop()
    public var task: (@escaping AsyncTask) -> Void = fiber
    public var awaiter: IOAwaiter? = TarantoolAwaiter()
}

public struct TarantoolAwaiterTimeout: Error {}

public struct TarantoolAwaiter: IOAwaiter {
    public init() {}

    public func wait(
        for descriptor: Int32,
        event: IOEvent,
        deadline: Date = Date.distantFuture
    ) throws {
        try COIOWrapper.wait(for: descriptor, event: event, deadline: deadline)
    }
}
