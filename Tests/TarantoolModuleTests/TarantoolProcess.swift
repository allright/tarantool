/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Platform
import Foundation

private struct Module {
    let name: String
    init(_ name: String) {
        self.name = name
    }

    var path: String? {
        return xcodeModuleUrl ?? swiftPMModuleUrl
    }

    private var xcodeModuleUrl: String? {
        guard let xcodeBuildDir = ProcessInfo.processInfo.environment["__XPC_DYLD_FRAMEWORK_PATH"],
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

private struct TarantoolProcessError: Error {
    let message: String
}

internal class TarantoolProcess {
    let process = Process()
    let port: UInt16
    let scriptBody: String

    var temp: URL = {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("TarantoolTemp\(arc4random())")
    }()

    var lock: URL {
        return temp.appendingPathComponent("lock")
    }

    init(port: UInt16 = 3301) throws {
        self.port = port
        self.scriptBody = "box.schema.user.create('tester', {password='tester'})\n" +
            "box.schema.user.grant('tester', 'read,write,eval,execute', 'universe')\n" +
            "box.schema.user.grant('guest', 'read,write,eval,execute', 'universe')\n" +
            "box.schema.func.create('hello')\n" +
            "function hello()\n" +
            "  return 'hey there!'\n" +
            "end\n"
    }

    init(loadingModule name: String, createFunctions: [String] = [], port: UInt16 = 3301) throws {
        self.port = port

        guard let module = Module(name).path else {
            throw TarantoolProcessError(message: "can't find swift module")
        }

        self.scriptBody = "package.cpath = '\(module);'..package.cpath\n" +
            "local ffi = require('ffi')\n" +
            "local lib = ffi.load('\(module)')\n" +
            "ffi.cdef[[void tarantool_module_init();]]\n" +
            "lib.tarantool_module_init()\n" +
            "box.schema.user.grant('guest', 'read,write,eval,execute', 'universe')\n" +
            createFunctions.reduce("") { $0 + "box.schema.func.create('\($1)', {language = 'C'})\n" }
    }

    @discardableResult
    func launch() throws  -> TarantoolProcess {
        let config = temp.appendingPathComponent("init.lua")
        let script = "box.cfg{listen=\(port),snap_dir='\(temp.path)',wal_dir='\(temp.path)',vinyl_dir='\(temp.path)',slab_alloc_arena=0.1}\n" +
            "\(scriptBody)\n" +
            "local fiber = require('fiber')\n" +
            "local fio = require('fio')\n" +
            "while fio.stat('\(lock.path)') do\n" +
            "  fiber.sleep(0.1)\n" +
            "end\n" +
            "os.exit(0)"

        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        _ = FileManager.default.createFile(atPath: lock.path, contents: nil)
        try script.write(to: config, atomically: true, encoding: .utf8)

    #if os(macOS)
        process.launchPath = "/usr/local/bin/tarantool"
    #else
        process.launchPath = "/usr/bin/tarantool"
    #endif
        process.arguments = [config.path]

        guard FileManager.default.fileExists(atPath: process.launchPath!) else {
            throw TarantoolProcessError(message: "\(process.launchPath!) doesn't exist")
        }

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.launch()
        sleep(1)
        guard process.isRunning else {
            let data = outputPipe.fileHandleForReading.availableData
            guard let output = String(data: data, encoding: .utf8) else {
                throw TarantoolProcessError(message: "can't launch tarantool")
            }
            throw TarantoolProcessError(message: output)
        }
        return self
    }

    func terminate() -> Int {
        if process.isRunning {
            // not yet implemented
            // process.terminate()
            try? FileManager.default.removeItem(at: lock)
            process.waitUntilExit()
        }
        try? FileManager.default.removeItem(at: temp)
        return Int(process.terminationStatus)
    }
}
