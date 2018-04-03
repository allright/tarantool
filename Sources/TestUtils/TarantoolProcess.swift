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
import Process
import class Foundation.ProcessInfo

extension String: Error {}

class TarantoolProcess {
    lazy var process: Process = {
        let path: String
        if let env_bin = ProcessInfo.processInfo.environment["TARANTOOL_BIN"] {
            path = env_bin
        } else {
            #if os(macOS)
            path = "/usr/local/bin/tarantool"
            #else
            path = "/usr/bin/tarantool"
            #endif
        }
        return Process(path: path)
    }()

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
        return process.status == .running
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

    deinit {
        try? Directory.remove(at: temp)
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

        process.arguments = [config.path.string]

        try process.launch()

        try waitForConnect()

        guard process.status == .running else {
            throw "can't launch tarantool"
        }
    }

    func waitForConnect() throws {
        let socket = try Socket()
            .bind(to: "127.0.0.1", port: syncPort)
            .listen()
        _ = try socket.accept(deadline: .now + 5.s)
    }

    func waitUntilExit() throws {
        try process.waitUntilExit()
    }

    func terminate() throws -> Int {
        if process.status == .running {
            try lock.remove()
            try waitUntilExit()
        }
        switch process.status {
        case .exited(code: let code): return code
        case .signaled(signal: let signal): return signal
        default: return -1
        }
    }
}
