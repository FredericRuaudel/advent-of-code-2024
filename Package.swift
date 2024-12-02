// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

enum Dependency {
    static let customDump: Target.Dependency = .product(name: "CustomDump", package: "swift-custom-dump")
    static let parsing: Target.Dependency = .product(name: "Parsing", package: "swift-parsing")
    static let issueReporting: Target.Dependency = .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
}

let package = Package(
    name: "adventOfCode2024",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Day1", targets: ["Day1"]),
        .library(name: "Day2", targets: ["Day2"]),
        .library(name: "Day3", targets: ["Day3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.4.3"),
    ],
    targets: [
        .executableTarget(
            name: "AoC24",
            dependencies: [
                "Core",
                "Day1",
                "Day2",
                "Day3",
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
        .target(name: "Day2", dependencies: [
            "Core",
            Dependency.parsing,
        ]),
        .testTarget(
            name: "Day2Tests",
            dependencies: [
                "Core",
                "Day2",
                Dependency.customDump,
                Dependency.parsing,
            ]
        ),
        .target(name: "Day3", dependencies: [
            "Core",
            Dependency.issueReporting,
            Dependency.parsing,
        ]),
        .testTarget(
            name: "Day3Tests",
            dependencies: [
                "Core",
                "Day3",
                Dependency.customDump,
                Dependency.parsing,
            ]
        ),
    ]
)
