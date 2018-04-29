import XCTest

extension BoxDataSourceTests {
    static let __allTests = [
        ("testCount", testCount),
        ("testDelete", testDelete),
        ("testGet", testGet),
        ("testInsert", testInsert),
        ("testLimit", testLimit),
        ("testReplace", testReplace),
        ("testSelect", testSelect),
        ("testUpdate", testUpdate),
        ("testUpsert", testUpsert),
    ]
}

extension BoxIndexTests {
    static let __allTests = [
        ("testBitset", testBitset),
        ("testCount", testCount),
        ("testDelete", testDelete),
        ("testGet", testGet),
        ("testHash", testHash),
        ("testInsert", testInsert),
        ("testMany", testMany),
        ("testReplace", testReplace),
        ("testRTree", testRTree),
        ("testSelect", testSelect),
        ("testSequence", testSequence),
        ("testTree", testTree),
        ("testUpdate", testUpdate),
        ("testUpsert", testUpsert),
    ]
}

extension BoxSchemaTests {
    static let __allTests = [
        ("testCreateSpace", testCreateSpace),
        ("testSchema", testSchema),
    ]
}

extension BoxSpaceTests {
    static let __allTests = [
        ("testCount", testCount),
        ("testDelete", testDelete),
        ("testGet", testGet),
        ("testInsert", testInsert),
        ("testReplace", testReplace),
        ("testSelect", testSelect),
        ("testSequence", testSequence),
        ("testStoreIndex", testStoreIndex),
        ("testUpdate", testUpdate),
        ("testUpsert", testUpsert),
    ]
}

extension BoxTransactionTests {
    static let __allTests = [
        ("testCommit", testCommit),
        ("testRollback", testRollback),
        ("testTCommit", testTCommit),
        ("testTRollback", testTRollback),
    ]
}

extension BoxTupleTests {
    static let __allTests = [
        ("testUnpackTuple", testUnpackTuple),
    ]
}

extension DispatchTests {
    static let __allTests = [
        ("testSyncTask", testSyncTask),
    ]
}

extension LuaTests {
    static let __allTests = [
        ("testEval", testEval),
        ("testPushPop", testPushPop),
        ("testPushPopArray", testPushPopArray),
        ("testPushPopMany", testPushPopMany),
        ("testPushPopMap", testPushPopMap),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BoxDataSourceTests.__allTests),
        testCase(BoxIndexTests.__allTests),
        testCase(BoxSchemaTests.__allTests),
        testCase(BoxSpaceTests.__allTests),
        testCase(BoxTransactionTests.__allTests),
        testCase(BoxTupleTests.__allTests),
        testCase(DispatchTests.__allTests),
        testCase(LuaTests.__allTests),
    ]
}
#endif
