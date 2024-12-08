import Algorithms
import Core
import IssueReporting

public struct Day8: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let map = try scanningAreaForAntennas(using: input)
        let antinodes = map.triangulatedAntinodesLocations()
        return antinodes.count.asText()
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }

    func scanningAreaForAntennas(using input: String) throws -> Map {
        var antennas = [Antenna]()
        let lines = input.split(separator: "\n")
        let height = lines.count
        var width = 0
        for (y, line) in lines.enumerated() {
            width = line.count
            for (x, frequency) in line.enumerated() {
                if frequency != "." {
                    antennas.append(Antenna(position: Coord(x, y), frequency: frequency))
                }
            }
        }
        guard let map = Map(width: width, height: height, antennas: antennas) else { throw Day8Error.invalidMapData }
        return map
    }
}

enum Day8Error: Error {
    case invalidMapData
}

struct Map: Equatable {
    var width: Int
    var height: Int
    var antennaPositionsByFrequencies: [Character: [Coord]]

    init?(width: Int, height: Int, antennas: [Antenna]) {
        guard antennas.count > 1 else { return nil }
        self.width = width
        self.height = height

        antennaPositionsByFrequencies = antennas.reduce(into: [:]) { positionDict, antenna in
            if positionDict[antenna.frequency] == nil {
                positionDict[antenna.frequency] = []
            }
            positionDict[antenna.frequency]?.append(antenna.position)
        }
    }

    func triangulatedAntinodesLocations() -> [Coord] {
        Array(
            antennaPositionsByFrequencies.values.reduce(into: []) { antinodes, antennaPositions in
                let allPairsOfAntennas = antennaPositions.allCombinationOfPairs()
                antinodes += allPairsOfAntennas.map { $0.pairOfAntinodes() }.flatMap { $0.asArray() }
            }
            .filter {
                $0.isInsideArea(width: self.width, height: self.height)
            }
            .uniqued()
        )
    }
}

struct Antenna: Equatable {
    var position: Coord
    var frequency: Character
}

extension Pair where A == Coord, B == Coord {
    func pairOfAntinodes() -> Self {
        Pair(
            Coord(first.x + (first.x - second.x), first.y + (first.y - second.y)),
            Coord(second.x + (second.x - first.x), second.y + (second.y - first.y))
        )
    }
}

extension Array where Element: Equatable {
    func allCombinationOfPairs() -> [Pair<Element, Element>] {
        var result = [Pair<Element, Element>]()
        var remainingElements = self
        while remainingElements.isEmpty == false {
            let head = remainingElements.removeFirst()
            for element in remainingElements {
                result.append(Pair(head, element))
            }
        }
        return result
    }
}

struct Pair<A: Equatable, B: Equatable>: Equatable {
    var first: A
    var second: B

    init(_ first: A, _ second: B) {
        self.first = first
        self.second = second
    }
}

extension Pair where A == B {
    func asArray() -> [A] {
        [first, second]
    }
}
