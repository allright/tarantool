import Time
import CTarantool

import struct Dispatch.DispatchQoS
import class Dispatch.DispatchQueue

public struct Fiber {
    public static let attr = fiber_attr_new()

    public static var stackSize: Int {
        get {
            return fiber_attr_getstacksize(attr)
        }
        set {
            _ = fiber_attr_setstacksize(attr, newValue)
        }
    }
}

@usableFromInline
var defaultStackSize: Void = {
    Fiber.stackSize = 4096 * 32
}()

@inline(__always)
public func fiber(_ closure: @escaping () -> Void) {
    _ = defaultStackSize
    var closure = closure
    fiber_wrapper_ex(&closure, Fiber.attr, { pointer in
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
    fiber_reschedule()
}

@inline(__always)
public func sleep(until deadline: Time) {
    fiber_sleep(Double(deadline.timeIntervalSinceNow))
}

@inline(__always)
public func now() -> Time {
    let time = fiber_time()
    return Time(seconds: Int(time), nanoseconds: 0)
}

@inline(__always)
public func transaction<T>(
    _ closure: () throws -> T
) throws -> T {
    return try Box.transaction(closure)
}
