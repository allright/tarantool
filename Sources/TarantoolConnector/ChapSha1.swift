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

import SHA1

extension Array where Element == UInt8 {
    func chapSha1(salt: [UInt8]) -> [UInt8] {
        let scrambleSize = 20

        var step1 = [UInt8](repeating: 0, count: scrambleSize)
        var step2 = [UInt8](repeating: 0, count: scrambleSize)
        var step3 = [UInt8](repeating: 0, count: scrambleSize)
        var scramble = [UInt8](repeating: 0, count: scrambleSize)

        step1 = self.sha1()
        step2 = step1.sha1()
        step3 = (salt.prefix(upTo: scrambleSize) + step2).sha1()

        for i in 0 ..< scrambleSize {
            scramble[i] = step1[i] ^ step3[i]
        }
        return scramble
    }
}
