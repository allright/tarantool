/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

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
