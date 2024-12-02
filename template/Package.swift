// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

let projectName = "AoC_dX"

enum Dependency {
    static let parsing: Target.Dependency = .product(name: "Parsing", package: "swift-parsing")
}

let package = Package(
    name: projectName,
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0")   
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(name: projectName, dependencies: [
            Dependency.parsing
        ]),
    ]
)
