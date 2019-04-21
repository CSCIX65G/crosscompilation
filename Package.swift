// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/CSCIX65G/smoke-framework.git", .branch("swift5")),
    .package(url: "https://github.com/AlwaysRightInstitute/Shell.git", from: "0.1.4"),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .branch("master")),
    .package(url: "https://github.com/CSCIX65G/SwiftyLinkerKit.git", .branch("swift5"))
]

let serverTargetDependencies: [Target.Dependency] = ["Service", "EchoService", "HeliumLogger", "Shell", "SwiftyLinkerKit"]

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
