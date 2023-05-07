// swift-tools-version: 5.7
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
        .package(url: "https://github.com/kean/Get", from: "2.1.6")
    ],
    targets: [
        .target(
            name: "CleverBird",
            dependencies: [
                .product(name: "Get", package: "Get")
            ],
            resources: [
                .process("tokenization/resources/gpt3-encoder.json"),
                .process("tokenization/resources/gpt3-vocab.bpe"),
            ]),
        .testTarget(
            name: "CleverBirdTests",
            dependencies: ["CleverBird"]),
    ]
)
