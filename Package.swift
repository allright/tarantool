// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Tarantool",
    products: [
        .library(
            name: "TarantoolConnector",
            targets: ["TarantoolConnector"]),
        .library(
            name: "TarantoolModule",
            targets: ["TarantoolModule"]),
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
            url: "https://github.com/tris-foundation/radix.git",
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
        .target(
            name: "CTarantool"),
        .target(
            name: "Tarantool",
            dependencies: ["MessagePack"]),
        .target(
            name: "TarantoolConnector",
            dependencies: ["Tarantool", "Network", "SHA1", "Base64"]),
        .target(
            name: "TarantoolModule",
            dependencies: ["CTarantool", "Tarantool", "Async", "Time"]),
        .target(
            name: "TarantoolModuleTest",
            dependencies: ["TarantoolModule"]),
        .target(
            name: "TestUtils",
            dependencies: ["Platform", "AIO", "Process"]),
        .target(
            name: "CTestUtils"),
        .testTarget(
            name: "TarantoolModuleTests",
            dependencies: [
                "Test",
                "Fiber",
                "CTestUtils",
                "TarantoolModule",
                "TarantoolConnector"]),
        .testTarget(
            name: "TarantoolConnectorTests",
            dependencies: ["TarantoolConnector", "Test", "Fiber"]),
        .testTarget(
            name: "TestUtilsTests",
            dependencies: ["TestUtils", "Test", "Fiber"])]
)
