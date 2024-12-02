// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

enum Dependency {
    static let parsing: Target.Dependency = .product(name: "Parsing", package: "swift-parsing")
}

let package = Package(
    name: "adventOfCode2024",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Day1", targets: ["Day1"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0"),
    ],
    targets: [
        .executableTarget(
            name: "AoC24",
            dependencies: [
                "Core",
                "Day1",
            ]
        ),
        .target(name: "Core"),
        .target(name: "Day1", dependencies: [
            "Core",
            Dependency.parsing,
        ]),
        .testTarget(
            name: "Day1Tests",
            dependencies: [
                "Core",
                "Day1",
            ]
        ),
    ]
)
