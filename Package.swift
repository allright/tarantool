// swift-tools-version:4.0
/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import PackageDescription

let package = Package(
    name: "Tarantool",
    products: [
        .library(name: "TarantoolConnector", targets: ["TarantoolConnector"]),
        .library(name: "TarantoolModule", targets: ["TarantoolModule"]),
        // used by TarantoolModuleTests
        .library(
            name: "TarantoolModuleTest",
            type: .dynamic,
            targets: ["TarantoolModuleTest"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/tris-foundation/platform.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/async.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/aio.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/time.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/crypto.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/messagepack.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/test.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/process.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/fiber.git",
            .branch("master"))
    ],
    targets: [
        .target(name: "CTarantool"),
        .target(name: "Tarantool", dependencies: ["MessagePack"]),
        .target(
            name: "TarantoolConnector",
            dependencies: ["Tarantool", "Network", "Crypto"]),
        .target(
            name: "TarantoolModule",
            dependencies: ["CTarantool", "Tarantool", "Async", "Time"]),
        .target(
            name: "TarantoolModuleTest",
            dependencies: ["TarantoolModule"]),
        .target(
            name: "TestUtils",
            dependencies: ["Platform", "AIO", "Process"]),
        .testTarget(
            name: "TarantoolModuleTests",
            dependencies: [
                "TarantoolModule", "TarantoolConnector", "Test", "Fiber"
            ]),
        .testTarget(
            name: "TarantoolConnectorTests",
            dependencies: ["TarantoolConnector", "Test", "Fiber"]),
        .testTarget(
            name: "TestUtilsTests",
            dependencies: ["TestUtils", "Test", "Fiber"])
    ]
)
