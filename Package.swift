// swift-tools-version:5.0
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
            url: "https://github.com/tris-code/platform.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/async.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/aio.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/time.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/crypto.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/messagepack.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/radix.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/test.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/process.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/fiber.git",
            .branch("master"))
    ],
    targets: [
        .target(
            name: "CTarantool",
            linkerSettings: [
                .unsafeFlags(
                    ["-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup"],
                    .when(platforms: [.macOS]))]),
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
