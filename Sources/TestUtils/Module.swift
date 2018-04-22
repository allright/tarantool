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

import Foundation

struct Module {
    let name: String
    init(_ name: String) {
        self.name = name
    }

    var path: String? {
        return xcodeModuleUrl ?? swiftPMModuleUrl
    }

    private var xcodeModuleUrl: String? {
        guard let xcodeBuildDir =
            ProcessInfo.processInfo.environment["__XPC_DYLD_FRAMEWORK_PATH"],
            !xcodeBuildDir.contains(":") else {
                return nil
        }
        return URL(fileURLWithPath: xcodeBuildDir)
            .appendingPathComponent("\(name).framework")
            .appendingPathComponent(name)
            .path
    }

    private var swiftPMModuleUrl: String? {
        var url = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(".build")
            .appendingPathComponent("debug")

        switch _isDebugAssertConfiguration() {
        case true: url.appendPathComponent("debug")
        case false: url.appendPathComponent("release")
        }
        url.deleteLastPathComponent()
        url.appendPathComponent("lib\(name)")
    #if os(macOS)
        url.appendPathExtension("dylib")
    #else
        url.appendPathExtension("so")
    #endif
        return url.path
    }
}
