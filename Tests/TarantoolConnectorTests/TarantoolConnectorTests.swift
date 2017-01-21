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
import Foundation
@testable import TarantoolConnector

class TarantoolConnectorTests: XCTestCase {
    let process = Process()

    var temp: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TarantoolConnectorTests")
    }

    var lock: URL {
        return temp.appendingPathComponent("lock")
    }

    override func setUp() {
        let config = temp.appendingPathComponent("init.lua")
        let script = "box.cfg{listen=3301,snap_dir='\(temp.path)',wal_dir='\(temp.path)',vinyl_dir='\(temp.path)',slab_alloc_arena=0.1}" +
            "box.schema.user.create('tester', {password='tester'})" +
            "box.schema.user.grant('tester', 'read,write,eval,execute', 'universe')" +
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

    func testTarantoolConnector() {
        do {
            let iproto = try IProtoConnection(host: "127.0.0.1")
            try iproto.auth(username: "tester", password: "tester")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    
    static var allTests : [(String, (TarantoolConnectorTests) -> () throws -> Void)] {
        return [
            ("testTarantoolConnector", testTarantoolConnector),
        ]
    }
}
