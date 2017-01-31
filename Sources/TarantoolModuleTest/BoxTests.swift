import TarantoolModule

@_silgen_name("testBox")
public func testBox(context: BoxContext) -> BoxResult {
    let source = BoxDataSource()
    do {
        let sysview = try source.select(spaceId: 281, indexId: 0, iterator: .all, keys: [], offset: 0, limit: Int.max)
        guard sysview.count >= 12 else {
            throw TarantoolError.invalidSchema
        }
        return Box.returnTuple(.map(["success": true]), to: context)
    } catch {
        return Box.returnError(code: .procC, message: String(describing: error))
    }
}
