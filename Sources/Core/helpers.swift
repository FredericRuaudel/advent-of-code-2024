import Foundation

public enum AoC24 {
    private static let currentDirectory = FileManager.default.currentDirectoryPath

    private static func input(forDay day: Int) throws -> String {
        let filepath = "\(currentDirectory)/Inputs/day\(day).txt"
        return try String(contentsOfFile: filepath, encoding: .utf8)
    }

    public static func run<T: AoCDay>(day: Int, using _: T.Type) throws {
        let dayInput = try input(forDay: day)
        let dayRunner = T()
        print("\nDay \(day) answers")
        print("-------------")
        try print("Part1: <\(dayRunner.runPart1(with: dayInput))>")
        try print("Part2: <\(dayRunner.runPart2(with: dayInput))>")
    }
}

public extension Int {
    func asText() -> String {
        "\(self)"
    }
}

public extension Array where Element == Int {
    func sum() -> Int {
        reduce(0,+)
    }
}

public struct Coord: Equatable, Hashable {
    public private(set) var x: Int
    public private(set) var y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public func isInsideArea(width: Int, height: Int) -> Bool {
        x >= 0 && y >= 0 &&
            x < width && y < height
    }
}

public extension Array where Element: Equatable {
    @discardableResult
    mutating func removeLastOccurrence(of element: Element) -> Element? {
        guard let lastIndex = lastIndex(of: element) else { return nil }
        return remove(at: lastIndex)
    }
}
