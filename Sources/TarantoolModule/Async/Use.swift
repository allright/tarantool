import Async
import Tarantool

extension Tarantool: Asynchronous {
    public static var async: Async {
        return AsyncTarantool()
    }
}
