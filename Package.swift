// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DrawerHelper",
    platforms: [.iOS(.v9), .tvOS(.v9)],
    products: [
        .library(
            name: "DrawerHelper",
            targets: ["DrawerHelper"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DrawerHelper",
            dependencies: []
        ),
        .testTarget(
            name: "DrawerHelperTests",
            dependencies: ["DrawerHelper"]
        ),
    ]
)
