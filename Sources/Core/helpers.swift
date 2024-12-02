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
