import Core
import Day1
import Foundation

let currentDirectory = FileManager.default.currentDirectoryPath

func input(forDay day: Int) throws -> String {
    let filepath = "\(currentDirectory)/Inputs/day\(day).txt"
    return try String(contentsOfFile: filepath, encoding: .utf8)
}

func run<T: AoCDay>(day: Int, using _: T.Type) throws {
    let dayInput = try input(forDay: day)
    let day = T()
    print("Day \(day) answers")
    print("-------------")
    try print("Part1: <\(day.runPart1(with: dayInput))>")
    try print("Part2: <\(day.runPart2(with: dayInput))>")
}

print("Hello, Advent Of Code!")
try run(day: 1, using: Day1.self)
