// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Delight",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "Delight", targets: ["Delight"]),
    ],
    targets: [
        .target(name: "Delight")
    ]
)
