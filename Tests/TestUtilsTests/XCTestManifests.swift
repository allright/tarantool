import XCTest

extension TestUtilsTests {
    static let __allTests = [
        ("testModulePath", testModulePath),
        ("testTarantoolProcess", testTarantoolProcess),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TestUtilsTests.__allTests),
    ]
}
#endif
