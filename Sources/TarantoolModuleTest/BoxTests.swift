import TarantoolModule

@_silgen_name("testBox")
public func testBox(context: BoxContext) -> BoxResult {
    let source = BoxDataSource()
    do {
        let sysview = try source.select(spaceId: 281, indexId: 0, iterator: .all, keys: [], offset: 0, limit: Int.max)
        return context.returnTuple(.map(["success": true]))
    } catch {
        return BoxError.returnError(code: .procC, message: String(describing: error))
    }
}
