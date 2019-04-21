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

let serverTargetDependencies: [Target.Dependency] = ["Service", "EchoService", "HeliumLogger", "Shell", "SwiftyLinkerKit", "GATT"]

let package = Package(
    name: "echoserver",
    products: [
        .executable(
            name: "echoserver",
            targets: [
                "Service",
                "EchoService",
                "Server",
            ]
        ),
        .library(name: "Service", targets: ["Service"]),
        .library(name: "EchoService", targets: ["EchoService", "Service"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "Server",
            dependencies: serverTargetDependencies
        ),
        .target(
            name: "EchoService",
            dependencies: ["Service", "SmokeOperations", "SmokeHTTP1", "SmokeOperationsHTTP1"]
        ),
        .target(
            name: "Service",
            dependencies: ["SmokeOperations", "SmokeHTTP1", "SmokeOperationsHTTP1"]
        ),
        .testTarget(
            name: "ServerTests",
            dependencies: ["Server"]
        ),
    ]
)
