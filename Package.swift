// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Delight",
    platforms: [.iOS(.v13), .macOS(.v10_10)],
    products: [
        .library(
            name: "Delight",
            targets: ["Delight"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/apple/swift-numerics", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "Delight",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
    ]
)
