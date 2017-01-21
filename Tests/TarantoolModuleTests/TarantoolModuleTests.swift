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
import TarantoolConnector
@testable import TarantoolModule

class TarantoolModuleTests: XCTestCase {
    let process = Process()

    var temp: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TarantoolModuleTests")
    }

    var lock: URL {
        return temp.appendingPathComponent("lock")
    }

    var xcodeModulePath: URL? {
        guard let xcodeBuildDir = ProcessInfo.processInfo.environment["__XPC_DYLD_FRAMEWORK_PATH"], !xcodeBuildDir.contains(":") else {
                return nil
        }
        return URL(fileURLWithPath: xcodeBuildDir)
            .appendingPathComponent("TarantoolModuleTest.framework")
            .appendingPathComponent("TarantoolModuleTest")
    }

    var swiftpmModulePath: URL? {
        guard var swiftpmBuildDir = URL(string: CommandLine.arguments[1]) else {
            return nil
        }
        swiftpmBuildDir.deleteLastPathComponent()
        swiftpmBuildDir.appendPathComponent("libTarantoolModuleTest")
    #if os(macOS)
        return swiftpmBuildDir.appendingPathExtension("dylib")
    #else
        return swiftpmBuildDir.appendingPathExtension("so")
    #endif
    }

    var modulePath: URL? {
        return xcodeModulePath ?? swiftpmModulePath
    }

    var moduleFunctions = [
        "testBox"
    ]

    var tarantoolPort: UInt16 = 3302

    override func setUp() {
        guard let module = modulePath else {
            XCTFail("can't find swift module")
            return
        }

        let config = temp.appendingPathComponent("init.lua")
        let script = "box.cfg{listen=\(tarantoolPort),snap_dir='\(temp.path)',wal_dir='\(temp.path)',vinyl_dir='\(temp.path)',slab_alloc_arena=0.1}\n" +
            "package.cpath = '\(module.path);'..package.cpath\n" +
            "local ffi = require('ffi')\n" +
            "local lib = ffi.load('\(module.path)')\n" +
            "ffi.cdef[[void tarantool_module_init();]]\n" +
            "lib.tarantool_module_init()\n" +
            "box.schema.user.grant('guest', 'read,write,eval,execute', 'universe')\n" +
            moduleFunctions.reduce("") { $0 + "box.schema.func.create('\($1)', {language = 'C'})\n" } +
            "local fiber = require('fiber')\n" +
            "local fio = require('fio')\n" +
            "while fio.stat('\(lock.path)') do \n" +
            "  fiber.sleep(0.1) \n" +
            "end \n" +
            "os.exit(0)"

        do {
            try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
            FileManager.default.createFile(atPath: lock.path, contents: nil)
            try script.write(to: config, atomically: true, encoding: .utf8)
        } catch {
            XCTFail(String(describing: error))
            return
        }

    #if os(macOS)
        process.launchPath = "/usr/local/bin/tarantool"
    #else
        process.launchPath = "/usr/bin/tarantool"
    #endif
        process.arguments = [config.path]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.launch()
        sleep(1)
        guard process.isRunning else {
            let data = outputPipe.fileHandleForReading.availableData
            if let outputString = String(data: data, encoding: .utf8) {
                XCTFail(outputString)
            } else {
                XCTFail("can't launch tarantool")
            }
            return
        }
    }

    override func tearDown() {
        if process.isRunning {
            // not yet implemented
            // process.terminate()
            try? FileManager.default.removeItem(at: lock)
            process.waitUntilExit()
        }
        try? FileManager.default.removeItem(at: temp)
        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testBox() {
        do {
            let iproto = try IProtoConnection(host: "127.0.0.1", port: tarantoolPort)
            let result = try iproto.call("testBox")
            guard let first = Tuple(result.first)?.first, let tuple = [MessagePack : MessagePack](first) else {
                throw TarantoolError.invalidTuple(message: "unexpected result")
            }
            XCTAssertEqual(tuple["success"], true)
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (TarantoolModuleTests) -> () throws -> Void)] {
        return [
            ("testBox", testBox),
        ]
    }
}
