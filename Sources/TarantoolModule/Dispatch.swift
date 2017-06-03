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
import Platform
import Dispatch
import CTarantool

import struct Foundation.Date
import Foundation

public struct DispatchWrapper {
    var isCanceled: Bool {
        return false
    }

    public static func syncTask<T>(
        qos: DispatchQoS.QoSClass = .background,
        deadline: Date = Date.distantFuture,
        task: @escaping () throws -> T
    ) throws -> T {
        var result: T? = nil
        var error: Error? = nil

        let fd = try pipe()

        try COIOWrapper.wait(for: fd.1, event: .write, deadline: deadline)

        // TODO: allow fibers inside the task
        // cord_create, cord_destroy, ev_run, ev_break
        DispatchQueue.global(qos: qos).async {
            // fiber {
            // ...
            //}
            // TarantoolLoop.current.run()
            do {
                result = try task()
            } catch let taskError {
                error = taskError
            }

            var done: UInt8 = 1
            write(fd.1, &done, 1)
        }

        try COIOWrapper.wait(for: fd.0, event: .read, deadline: deadline)

        close(fd.0)
        close(fd.1)

        if let result = result {
            return result
        } else if let error = error {
            throw error
        }

        throw AsyncError.taskCanceled
    }

    fileprivate static func pipe() throws -> (Descriptor, Descriptor) {
        var fd: (Descriptor, Descriptor) = (0, 0)
        let pointer = UnsafeMutableRawPointer(&fd)
            .assumingMemoryBound(to: Int32.self)
        guard Platform.pipe(pointer) != -1 else {
            throw SystemError()
        }
        return fd
    }
}