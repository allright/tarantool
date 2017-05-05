/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

func throwNotEqual<T>(value1: T, value2: T) throws -> Never {
    throw "\(value1) is not equal to \(value2)"
}

func assertEqualThrows<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Equatable {
    let result1 = try expression1()
    let result2 = try expression2()

    guard result1 == result2 else {
        try throwNotEqual(value1: result1, value2: result2)
    }
}

func assertEqualThrows<T>(
    _ expression1: @autoclosure () throws -> T?,
    _ expression2: @autoclosure () throws -> T?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Equatable {
    let result1 = try expression1()
    let result2 = try expression2()
    guard result1 != nil && result2 != nil else {
        if (result1 == nil && result2 != nil) ||
            (result1 != nil && result2 == nil) {
                try throwNotEqual(value1: result1, value2: result2)
        }
        return

    }
    try assertEqualThrows(result1!, result2!)
}

func assertEqualThrows<T>(
    _ expression1: @autoclosure () throws -> ArraySlice<T>,
    _ expression2: @autoclosure () throws -> ArraySlice<T>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Equatable {
    let result1 = try expression1()
    let result2 = try expression2()
    guard result1.elementsEqual(result2) else {
        try throwNotEqual(value1: result1, value2: result2)
    }
}

func assertEqualThrows<T>(
    _ expression1: @autoclosure () throws -> ContiguousArray<T>,
    _ expression2: @autoclosure () throws -> ContiguousArray<T>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Equatable {
    let result1 = try expression1()
    let result2 = try expression2()
    guard result1.elementsEqual(result2) else {
        try throwNotEqual(value1: result1, value2: result2)
    }
}

func assertEqualThrows<T>(
    _ expression1: @autoclosure () throws -> [T],
    _ expression2: @autoclosure () throws -> [T],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Equatable {
    let result1 = try expression1()
    let result2 = try expression2()
    guard result1.elementsEqual(result2) else {
        try throwNotEqual(value1: result1, value2: result2)
    }
}

func assertEqualThrows<T, U>(
    _ expression1: @autoclosure () throws -> [T : U],
    _ expression2: @autoclosure () throws -> [T : U],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) throws where T : Hashable, U : Equatable {
    let result1 = try expression1()
    let result2 = try expression2()
    guard result1 == result2 else {
        try throwNotEqual(value1: result1, value2: result2)
    }
}
