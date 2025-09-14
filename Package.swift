// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyStats",
    platforms: [
        .iOS(.v15),
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftyStats",
            targets: ["SwiftyStats"]),
        ],
    dependencies: [
        // DocC plugin for documentation generation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftyStats",
            dependencies: [],
            path: "./SwiftyStats/CommonSource",
            cSettings:[
                .define("ACCELERATE_NEW_LAPACK"),
            ],
            swiftSettings:[
                .define("ACCELERATE_NEW_LAPACK")
            ],
            linkerSettings: [
                .linkedFramework("Accelerate", .when(platforms: [.macOS, .iOS]))
            ]
        ),
        .testTarget(
            name: "SwiftyStatsTests",
            dependencies: ["SwiftyStats"],
            path: "./SwiftyStats/CommonTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
