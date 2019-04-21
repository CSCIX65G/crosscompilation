// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/CSCIX65G/smoke-framework.git", .branch("swift5")),
    .package(url: "https://github.com/CSCIX65G/Shell.git", .branch("swift5")),
    .package(url: "https://github.com/CSCIX65G/SwiftyLinkerKit.git", .branch("swift5")),
    .package(url: "https://github.com/ComputeCycles/GATT.git", .branch("swift5")),
    .package(url: "https://github.com/ComputeCycles/BluetoothLinux.git", .branch("swift5")),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .branch("master"))
]

let serverTargetDependencies: [Target.Dependency] = [
    "SmokeService",
    "EchoService",
    "HeliumLogger",
    "Shell",
    "SwiftyLinkerKit",
    "GATT",
    "BluetoothLinux"
]

let package = Package(
    name: "echoserver",
    products: [
        .executable(
            name: "echoserver",
            targets: [
                "SmokeService",
                "EchoService",
                "Server",
            ]
        ),
        .library(name: "SmokeService", targets: ["SmokeService"]),
        .library(name: "ClockService", targets: ["ClockService", "SmokeService"]),
        .library(name: "BluetootService", targets: ["BluetoothService", "SmokeService"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "Server",
            dependencies: serverTargetDependencies
        ),
        .target(
            name: "EchoService",
            dependencies: ["SmokeService"]
        ),
        .target(
            name: "ClockService",
            dependencies: ["SmokeService"]
        ),
        .target(
            name: "BluetoothService",
            dependencies: ["SmokeService"]
        ),
        .target(
            name: "SmokeService",
            dependencies: ["SmokeOperations", "SmokeHTTP1", "SmokeOperationsHTTP1"]
        ),
        .testTarget(
            name: "ServerTests",
            dependencies: ["Server"]
        ),
    ]
)
