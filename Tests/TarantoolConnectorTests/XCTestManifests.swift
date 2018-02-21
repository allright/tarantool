import XCTest

extension CHAPSHA1Tests {
    static let __allTests = [
        ("testCHAPSHA1", testCHAPSHA1),
    ]
}

extension IProtoConnectionTests {
    static let __allTests = [
        ("testAuth", testAuth),
        ("testCall", testCall),
        ("testEval", testEval),
        ("testPing", testPing),
        ("testRequest", testRequest),
    ]
}

extension IProtoDataSourceTests {
    static let __allTests = [
        ("testCount", testCount),
        ("testDelete", testDelete),
        ("testGet", testGet),
        ("testInsert", testInsert),
        ("testReplace", testReplace),
        ("testSelect", testSelect),
        ("testUpdate", testUpdate),
        ("testUpsert", testUpsert),
    ]
}

extension IProtoIndexTests {
    static let __allTests = [
        ("testArrayPartType", testArrayPartType),
        ("testBitset", testBitset),
        ("testBooleanPartType", testBooleanPartType),
        ("testCount", testCount),
        ("testDelete", testDelete),
        ("testGet", testGet),
        ("testHash", testHash),
        ("testInsert", testInsert),
        ("testIntegerPartType", testIntegerPartType),
        ("testMany", testMany),
        ("testNumberPartType", testNumberPartType),
        ("testReplace", testReplace),
        ("testRTree", testRTree),
        ("testScalarPartType", testScalarPartType),
        ("testSelect", testSelect),
        ("testSequence", testSequence),
        ("testStringPartType", testStringPartType),
        ("testTree", testTree),
        ("testUnsignedPartType", testUnsignedPartType),
        ("testUpdate", testUpdate),
        ("testUppercased", testUppercased),
        ("testUpsert", testUpsert),
    ]
}

extension IProtoIteratorTests {
    static let __allTests = [
        ("testSelectAll", testSelectAll),
        ("testSelectEQ", testSelectEQ),
        ("testSelectGE", testSelectGE),
        ("testSelectGT", testSelectGT),
        ("testSelectLE", testSelectLE),
        ("testSelectLT", testSelectLT),
    ]
}

extension IProtoSchemaTests {
    static let __allTests = [
        ("testCreateSpace", testCreateSpace),
        ("testSchema", testSchema),
    ]
}

extension IProtoSpaceTests {
    static let __allTests = [
        ("testCount", testCount),
        ("testDelete", testDelete),
        ("testGet", testGet),
        ("testInsert", testInsert),
        ("testReplace", testReplace),
        ("testSelect", testSelect),
        ("testSequence", testSequence),
        ("testUpdate", testUpdate),
        ("testUpsert", testUpsert),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CHAPSHA1Tests.__allTests),
        testCase(IProtoConnectionTests.__allTests),
        testCase(IProtoDataSourceTests.__allTests),
        testCase(IProtoIndexTests.__allTests),
        testCase(IProtoIteratorTests.__allTests),
        testCase(IProtoSchemaTests.__allTests),
        testCase(IProtoSpaceTests.__allTests),
    ]
}
#endif
