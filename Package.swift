// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

enum Dependency {
    static let algorithms: Target.Dependency = .product(name: "Algorithms", package: "swift-algorithms")
    static let casePaths: Target.Dependency = .product(name: "CasePaths", package: "swift-case-paths")
    static let customDump: Target.Dependency = .product(name: "CustomDump", package: "swift-custom-dump")
    static let issueReporting: Target.Dependency = .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
    static let orderedCollections: Target.Dependency = .product(
        name: "OrderedCollections",
        package: "swift-collections"
    )
    static let parsing: Target.Dependency = .product(name: "Parsing", package: "swift-parsing")
}

let package = Package(
    name: "adventOfCode2024",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Day1", targets: ["Day1"]),
        .library(name: "Day2", targets: ["Day2"]),
        .library(name: "Day3", targets: ["Day3"]),
        .library(name: "Day4", targets: ["Day4"]),
        .library(name: "Day5", targets: ["Day5"]),
        .library(name: "Day6", targets: ["Day6"]),
        .library(name: "Day7", targets: ["Day7"]),
        .library(name: "Day8", targets: ["Day8"]),
        .library(name: "Day9", targets: ["Day9"]),
        .library(name: "Day10", targets: ["Day10"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.5.6"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0"),
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
                "Day4",
                "Day5",
                "Day6",
                "Day7",
                "Day8",
                "Day9",
                "Day10",
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
        .target(name: "Day4", dependencies: [
            "Core",
            Dependency.issueReporting,
        ]),
        .testTarget(
            name: "Day4Tests",
            dependencies: [
                "Core",
                "Day4",
                Dependency.customDump,
            ]
        ),
        .target(name: "Day5", dependencies: [
            "Core",
            Dependency.issueReporting,
            Dependency.orderedCollections,
            Dependency.parsing,
        ]),
        .testTarget(
            name: "Day5Tests",
            dependencies: [
                "Core",
                "Day5",
                Dependency.customDump,
                Dependency.orderedCollections,
            ]
        ),
        .target(name: "Day6", dependencies: [
            "Core",
        ]),
        .testTarget(
            name: "Day6Tests",
            dependencies: [
                "Core",
                "Day6",
                Dependency.customDump,
            ]
        ),
        .target(name: "Day7", dependencies: [
            "Core",
            Dependency.parsing,
        ]),
        .testTarget(
            name: "Day7Tests",
            dependencies: [
                "Core",
                "Day7",
                Dependency.customDump,
            ]
        ),
        .target(name: "Day8", dependencies: [
            "Core",
            Dependency.algorithms,
            Dependency.issueReporting,
        ]),
        .testTarget(
            name: "Day8Tests",
            dependencies: [
                "Core",
                "Day8",
                Dependency.customDump,
            ]
        ),
        .target(name: "Day9", dependencies: [
            "Core",
            Dependency.casePaths,
        ]),
        .testTarget(
            name: "Day9Tests",
            dependencies: [
                "Core",
                "Day9",
                Dependency.customDump,
            ]
        ),
        .target(name: "Day10", dependencies: [
            "Core",
        ]),
        .testTarget(
            name: "Day10Tests",
            dependencies: [
                "Core",
                "Day10",
                Dependency.customDump,
            ]
        ),
    ]
)
