/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

func assertTrueThrows(
    _ expression: @autoclosure () throws -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws
{
    guard try expression() else {
        throw "false"
    }
}

func assertEqualThrows<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Equatable
{
    let result1 = try expression1()
    let result2 = try expression2()

    guard result1 == result2 else {
        throw "\(result1) is not equal to \(result2)"
    }
}

func assertNotEqualThrows<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Equatable
{
    let result1 = try expression1()
    let result2 = try expression2()

    guard result1 != result2 else {
        throw "\(result1) is equal to \(result2)"
    }
}
