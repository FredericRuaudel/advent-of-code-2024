import Core
import Foundation
import Parsing

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

extension String {
    func toCharacterGrid() -> [String] {
        components(separatedBy: "\n")
    }
}

extension Array where Element == String {
    func char(at coord: Coord) -> Character? {
        guard coord.y >= 0 && coord.y < count else { return nil }
        let line = self[coord.y]
        guard coord.x >= 0 && coord.x < line.count else { return nil }
        let index = line.index(line.startIndex, offsetBy: coord.x)
        return line[index]
    }

    func allXCoords() -> [Coord] {
        var result: [Coord] = []
        for (y, line) in enumerated() {
            for (x, letter) in line.enumerated() {
                if letter == "X" {
                    result.append(Coord(x, y))
                }
            }
        }
        return result
    }

    func fourLetters(from origin: Coord, towards direction: Direction) -> String? {
        var result = ""
        var nextCoord = origin
        while result.count < 4 {
            if let nextLetter = char(at: nextCoord) {
                result += String(nextLetter)
                nextCoord = nextCoord + direction.offset
            } else {
                return nil
            }
        }
        return result
    }

    func allFourLetters(from origin: Coord) -> [String] {
        Direction.allCases.compactMap { direction in
            fourLetters(from: origin, towards: direction)
        }
    }
}

public struct Day4: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let letterGrid = input.toCharacterGrid()
        let allXCoords = letterGrid.allXCoords()
        let xmasCount = allXCoords.flatMap {
            letterGrid.allFourLetters(from: $0)
        }
        .filter { $0 == "XMAS" }
        .count
        return "\(xmasCount)"
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }
}
