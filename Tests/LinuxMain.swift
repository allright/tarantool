/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import XCTest
@testable import TestUtilsTests
@testable import TarantoolModuleTests
@testable import TarantoolConnectorTests

XCTMain([
     testCase(TestUtilsTests.allTests),
     testCase(BoxDataSourceTests.allTests),
     testCase(BoxSpaceTests.allTests),
     testCase(IProtoConnectionTests.allTests),
     testCase(IProtoDataSourceTests.allTests),
     testCase(IProtoIteratorTests.allTests),
     testCase(IProtoSchemaTests.allTests),
     testCase(IProtoSpaceTests.allTests),
     testCase(CHAPSHA1Tests.allTests),
])
