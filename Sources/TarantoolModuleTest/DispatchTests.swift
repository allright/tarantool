import Time
import CTarantool
import TarantoolModule

struct DispatchTests {
    static func testSyncTask() throws {
        var iterations: Int = 0

        fiber {
            while iterations < 10 {
                // tick tock tick tock
                sleep(until: .now + 90.ms)
                iterations += 1
            }
        }

        var result = 0
        var iterationsAtStart = 0
        var iterationsAfterOneSecond = 0

        do {
            result = try syncTask {
                iterationsAtStart = iterations
                // block thread
                sleep(1)
                iterationsAfterOneSecond = iterations
                return 42
            }
        } catch {
            throw error
        }

        try assertEqualThrows(result, 42)
        try assertEqualThrows(iterationsAtStart, 0)
        try assertEqualThrows(iterationsAfterOneSecond, 10)
    }
}

// C API Wrappers

@_silgen_name("DispatchTests_testSyncTask")
public func DispatchTests_testSyncTask(context: Box.Context) -> Box.Result {
    return Box.execute {
        try DispatchTests.testSyncTask()
    }
}
