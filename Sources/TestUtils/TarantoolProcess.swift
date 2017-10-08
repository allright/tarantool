/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Network
import Platform
import Foundation

extension String: Error {}

class TarantoolProcess {
    let process = Process()
    let port: UInt16
    let script: String

    private let syncPort: UInt16

    var temp: URL = {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("TarantoolTemp\(arc4random())")
    }()

    var lock: URL {
        return temp.appendingPathComponent("lock")
    }

    var isRunning: Bool {
        return process.isRunning
    }

    var log: String? {
        let logUrl = temp.appendingPathComponent("tarantool.log")
        guard let data = try? Data(contentsOf: logUrl),
            let log = String(data: data, encoding: .utf8) else {
                return nil
        }
        return log
    }

    init(with script: String = "") throws {
        self.syncPort = UInt16(arc4random_uniform(64_000)) + 1_500
        self.port = UInt16(arc4random_uniform(64_000)) + 1_500
        self.script = script
    }

    deinit {
        cleanup()
    }

    func launch() throws {
        let config = temp.appendingPathComponent("init.lua")
        let script = """
            box.cfg{
              listen=\(port),
              log='\(temp.path)/tarantool.log',
              memtx_dir='\(temp.path)',
              wal_dir='\(temp.path)',
              vinyl_dir='\(temp.path)',
              memtx_memory=100000000
            }
            \(self.script)
            local fiber = require('fiber')
            local fio = require('fio')
            local net = require('net.box')
            net.connect('127.0.0.1:\(syncPort)')
            while fio.stat('\(lock.path)') do
              fiber.sleep(0.1)
            end
            os.exit(0)
            """

        try FileManager.default.createDirectory(
            at: temp, withIntermediateDirectories: true)
        _ = FileManager.default.createFile(atPath: lock.path, contents: nil)
        try script.write(to: config, atomically: true, encoding: .utf8)

        if let env_bin = ProcessInfo.processInfo.environment["TARANTOOL_BIN"] {
            process.launchPath = env_bin
        } else {
        #if os(macOS)
            process.launchPath = "/usr/local/bin/tarantool"
        #else
            process.launchPath = "/usr/bin/tarantool"
        #endif
        }

        process.arguments = [config.path]

        guard FileManager.default.fileExists(atPath: process.launchPath!) else {
            throw "\(process.launchPath!) doesn't exist"
        }

        process.launch()

        try waitForConnect()

        guard process.isRunning else {
            throw "can't launch tarantool"
        }
    }

    func waitForConnect() throws {
        let socket = try Socket()
            .bind(to: "127.0.0.1", port: syncPort)
            .listen()
        _ = try socket.accept(deadline: Date(timeIntervalSinceNow: 5))
    }

    func terminate() -> Int {
        if process.isRunning {
            // not yet implemented
            // process.terminate()
            try? FileManager.default.removeItem(at: lock)
            process.waitUntilExit()
        }
        return Int(process.terminationStatus)
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: temp)
    }
}
