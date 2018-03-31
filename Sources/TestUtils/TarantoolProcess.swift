/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Time
import File
import Network
import Platform
import Foundation

extension String: Error {}

class TarantoolProcess {
    let process = Process()
    let port: Int
    let script: String

    private let syncPort: Int

    let temp = Path(string: "/tmp/TarantoolTemp\(arc4random())")

    var lock: File {
        return File(name: "lock", at: temp)
    }

    var logFile: File {
        return File(name: "tarantool.log", at: temp)
    }

    var isRunning: Bool {
        return process.isRunning
    }

    var log: String? {
        return try? logFile
            .open(flags: .read)
            .inputStream
            .readUntilEnd(as: String.self)
    }

    init(with script: String = "") throws {
        self.syncPort = Int(arc4random_uniform(64_000)) + 1_500
        self.port = Int(arc4random_uniform(64_000)) + 1_500
        self.script = script
    }

    func launch() throws {
        let script = """
            box.cfg{
              listen=\(port),
              log='\(logFile.path.string)',
              memtx_dir='\(temp.string)',
              wal_dir='\(temp.string)',
              vinyl_dir='\(temp.string)',
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

        try Directory.create(at: temp)
        try lock.create()

        let config = File(name: "init.lua", at: temp)
        let stream = try config.open(flags: [.create, .truncate, .write])
        try stream.write(script)
        try stream.flush()

        if let env_bin = ProcessInfo.processInfo.environment["TARANTOOL_BIN"] {
            process.launchPath = env_bin
        } else {
        #if os(macOS)
            process.launchPath = "/usr/local/bin/tarantool"
        #else
            process.launchPath = "/usr/bin/tarantool"
        #endif
        }

        process.arguments = [config.path.string]

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
        _ = try socket.accept(deadline: .now + 5.s)
    }

    func terminate() -> Int {
        if process.isRunning {
            // not yet implemented
            // process.terminate()
            try? lock.remove()
            process.waitUntilExit()
            try? Directory.remove(at: temp)
        }
        return Int(process.terminationStatus)
    }
}
