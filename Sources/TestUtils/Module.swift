/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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
        #if os(macOS)
            let xctest = CommandLine.arguments[1]
        #else
            let xctest = CommandLine.arguments[0]
        #endif
        guard var url = URL(string: xctest) else {
            return nil
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
