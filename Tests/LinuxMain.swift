import XCTest

import TarantoolModuleTests
import TarantoolConnectorTests
import TestUtilsTests

var tests = [XCTestCaseEntry]()
tests += TarantoolModuleTests.__allTests()
tests += TarantoolConnectorTests.__allTests()
tests += TestUtilsTests.__allTests()

XCTMain(tests)
