import Core
import Foundation

public struct Day4: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let letterGrid = input.toCharacterGrid()
        let allXCoords = letterGrid.allCoords(of: "X")
        let xmasCount = allXCoords.flatMap { letterXCoord in
            letterGrid.allFourLetters(from: letterXCoord)
        }
        .filter { foundWord in
            foundWord == "XMAS"
        }
        .count
        return "\(xmasCount)"
    }

    public func runPart2(with input: String) throws -> String {
        let letterGrid = input.toCharacterGrid()
        let allACoords = letterGrid.allCoords(of: "A")
        let crosswordsCount = allACoords.compactMap { letterACoord in
            letterGrid.crossWords(centeredAt: letterACoord)
        }
        .filter { pairFound in
            ["MAS", "SAM"].contains(pairFound.topLeft) &&
                ["MAS", "SAM"].contains(pairFound.topRight)
        }
        .count
        return "\(crosswordsCount)"
    }
}

extension String {
    func toCharacterGrid() -> [String] {
        components(separatedBy: "\n")
    }
}

extension Array where Element == String {
    func allCoords(of character: Character) -> [Coord] {
        var result: [Coord] = []
        for (y, line) in enumerated() {
            for (x, letter) in line.enumerated() {
                if letter == character {
                    result.append(Coord(x, y))
                }
            }
        }
        return result
    }

    func allFourLetters(from origin: Coord) -> [String] {
        Direction.allCases.compactMap { direction in
            fourLetters(from: origin, towards: direction)
        }
    }

    func fourLetters(from origin: Coord, towards direction: Direction) -> String? {
        word(from: origin, towards: direction, ofLength: 4)
    }

    func word(from origin: Coord, towards direction: Direction, ofLength count: Int) -> String? {
        var result = ""
        var nextCoord = origin
        while result.count < count {
            if let nextLetter = char(at: nextCoord) {
                result += String(nextLetter)
                nextCoord = nextCoord + direction.offset
            } else {
                return nil
            }
        }
        return result
    }

    func char(at coord: Coord) -> Character? {
        guard coord.y >= 0 && coord.y < count else { return nil }
        let line = self[coord.y]
        guard coord.x >= 0 && coord.x < line.count else { return nil }
        let index = line.index(line.startIndex, offsetBy: coord.x)
        return line[index]
    }

    func crossWords(centeredAt center: Coord) -> Pair<String>? {
        guard
            let northWestLetter = char(at: center + Direction.northWest.offset),
            let northEastLetter = char(at: center + Direction.northEast.offset),
            let centerLetter = char(at: center),
            let southWestLetter = char(at: center + Direction.southWest.offset),
            let southEastLetter = char(at: center + Direction.southEast.offset)
        else {
            return nil
        }

        return Pair(
            topLeft: String([northWestLetter, centerLetter, southEastLetter]),
            topRight: String([northEastLetter, centerLetter, southWestLetter])
        )
    }
}

struct Coord: Equatable {
    var x: Int
    var y: Int
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        Coord(lhs.x + rhs.x, lhs.y + rhs.y)
    }
}

enum Direction: Equatable, CaseIterable {
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest

    var offset: Coord {
        switch self {
        case .north:
            Coord(0, -1)
        case .northEast:
            Coord(1, -1)
        case .east:
            Coord(1, 0)
        case .southEast:
            Coord(1, 1)
        case .south:
            Coord(0, 1)
        case .southWest:
            Coord(-1, 1)
        case .west:
            Coord(-1, 0)
        case .northWest:
            Coord(-1, -1)
        }
    }
}

struct Pair<A: Equatable>: Equatable {
    var topLeft: A
    var topRight: A
}
