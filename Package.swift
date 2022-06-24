// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ParsableCommands",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library( name: "ParsableCommands", targets: ["ParsableCommands"]),
        .executable(name: "Example", targets: ["Example"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ParsableCommands",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser") ]),
        .target(name: "Example", dependencies: ["ParsableCommands"]),
        .testTarget(
            name: "ParsableCommandsTests",
            dependencies: ["ParsableCommands"]),
    ]
)
