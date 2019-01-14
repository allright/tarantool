import XCTest

import TarantoolConnectorTests
import TarantoolModuleTests
import TestUtilsTests

var tests = [XCTestCaseEntry]()
tests += TarantoolConnectorTests.__allTests()
tests += TarantoolModuleTests.__allTests()
tests += TestUtilsTests.__allTests()

XCTMain(tests)
