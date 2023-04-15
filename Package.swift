// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleverBird",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v16), .watchOS(.v9)
    ],
    products: [
        .library(
            name: "CleverBird",
            targets: ["CleverBird"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "CleverBird",
            dependencies: [],
            resources: [
                .process("models/gpt3-encoder.json"),
                .process("models/gpt3-vocab.bpe"),
            ]),
        .testTarget(
            name: "CleverBirdTests",
            dependencies: ["CleverBird"]),
    ]
)
