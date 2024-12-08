import Core
import CustomDump
@testable import Day8
import Testing

struct Day8Tests {
    let inputPart = """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """

    @Test("An Antenna should have position and frequency properties set via init")
    func antennaPropertiesTest() {
        let antenna = Antenna(position: Coord(5, 3), frequency: "a")

        #expect(antenna.position.x == 5)
        #expect(antenna.position.y == 3)
        #expect(antenna.frequency == "a")

        let antenna2 = Antenna(position: Coord(-2, 10), frequency: "Z")
        #expect(antenna2.position.x == -2)
        #expect(antenna2.position.y == 10)
        #expect(antenna2.frequency == "Z")
    }

    @Test("A Map should be init with width, height and at least two antennas")
    func mapInitTest() {
        #expect(Map(width: 10, height: 10, antennas: []) == nil)
        #expect(Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
        ]) == nil)

        #expect(Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "b"),
        ]) != nil)

        #expect(Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "b"),
            Antenna(position: Coord(3, 3), frequency: "c"),
        ]) != nil)
    }

    @Test("A Map should have width and height properties set via init")
    func mapPropertiesTest() {
        let map = Map(width: 10, height: 15, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "b"),
        ])

        #expect(map?.width == 10)
        #expect(map?.height == 15)

        let map2 = Map(width: 20, height: 25, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "b"),
            Antenna(position: Coord(3, 3), frequency: "c"),
        ])

        #expect(map2?.width == 20)
        #expect(map2?.height == 25)
    }

    @Test("A Map should have an antennaPositionsByFrequencies property of type [Character:[Coord]] initialized with antennas argument")
    func mapAntennaPositionsByFrequenciesTest() {
        let map = Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "b"),
            Antenna(position: Coord(3, 3), frequency: "a"),
        ])

        expectNoDifference(map?.antennaPositionsByFrequencies, [
            "a": [Coord(1, 1), Coord(3, 3)],
            "b": [Coord(2, 2)],
        ])

        let map2 = Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(1, 1), frequency: "x"),
            Antenna(position: Coord(2, 2), frequency: "y"),
        ])

        expectNoDifference(map2?.antennaPositionsByFrequencies, [
            "x": [Coord(1, 1)],
            "y": [Coord(2, 2)],
        ])
    }

    @Test("Array.allCombinationOfPairs() should return all unique pairs of elements")
    func allCombinationOfPairsTest() {
        let array1 = [1, 2, 3]
        expectNoDifference(array1.allCombinationOfPairs(), [
            Pair(1, 2),
            Pair(1, 3),
            Pair(2, 3),
        ])

        let array2 = ["a", "b", "c", "d"]
        expectNoDifference(array2.allCombinationOfPairs(), [
            Pair("a", "b"),
            Pair("a", "c"),
            Pair("a", "d"),
            Pair("b", "c"),
            Pair("b", "d"),
            Pair("c", "d"),
        ])

        let array3 = [true, false]
        expectNoDifference(array3.allCombinationOfPairs(), [
            Pair(true, false),
        ])

        let array4 = [1]
        expectNoDifference(array4.allCombinationOfPairs(), [])

        let array5: [Int] = []
        expectNoDifference(array5.allCombinationOfPairs(), [])
    }

    @Test("A Pair of Coord should have a method pairOfAntinodes that returns the two antinodes created by these antennas")
    func pairOfAntinodesTest() {
        let pair1 = Pair(Coord(1, 2), Coord(3, 4))
        expectNoDifference(pair1.pairOfAntinodes(), Pair(Coord(-1, 0), Coord(5, 6)))
        let pair2 = Pair(Coord(2, 2), Coord(3, 1))
        expectNoDifference(pair2.pairOfAntinodes(), Pair(Coord(1, 3), Coord(4, 0)))
    }

    @Test("A Pair should have a method asArray() that returns an array containing first then second element")
    func pairAsArrayTest() {
        let pair1 = Pair(1, 2)
        expectNoDifference(pair1.asArray(), [1, 2])

        let pair2 = Pair("hello", "world")
        expectNoDifference(pair2.asArray(), ["hello", "world"])

        let pair3 = Pair(true, false)
        expectNoDifference(pair3.asArray(), [true, false])

        let pair4 = Pair(Coord(1, 2), Coord(3, 4))
        expectNoDifference(pair4.asArray(), [Coord(1, 2), Coord(3, 4)])
    }

    @Test("Map.triangulatedAntinodesLocations() should return all antinodes from pairs of antennas with same frequency on the map")
    func triangulatedAntinodesLocationsTest() throws {
        let map = try #require(Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
            Antenna(position: Coord(3, 3), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "b"),
            Antenna(position: Coord(4, 4), frequency: "b"),
            Antenna(position: Coord(5, 5), frequency: "c"),
        ]))
        expectNoDifference(Set(map.triangulatedAntinodesLocations()), Set([
            Coord(5, 5),
            Coord(0, 0),
            Coord(6, 6),
        ]))

        let mapWithNoAntinodePairs = try #require(Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(1, 1), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "b"),
        ]))

        expectNoDifference(Set(mapWithNoAntinodePairs.triangulatedAntinodesLocations()), Set([]))

        let mapWithDuplicatedAntinodes = try #require(Map(width: 10, height: 10, antennas: [
            Antenna(position: Coord(3, 1), frequency: "a"),
            Antenna(position: Coord(2, 2), frequency: "a"),
            Antenna(position: Coord(3, 0), frequency: "b"),
            Antenna(position: Coord(2, 0), frequency: "b"),
        ]))

        let antinodes = mapWithDuplicatedAntinodes.triangulatedAntinodesLocations()
        expectNoDifference(Set(antinodes), Set([
            Coord(4, 0),
            Coord(1, 0),
            Coord(1, 3),
        ]))
        #expect(antinodes.count == 3)
    }

    @Test("Day8.scanningAreaForAntennas() should parse a string input into a Map with antennas")
    func scanningAreaForAntennasTest() throws {
        let day8 = Day8()
        let map = try day8.scanningAreaForAntennas(using: inputPart)

        #expect(map.width == 12)
        #expect(map.height == 12)

        let expectedAntennasByFrequency: [Character: [Coord]] = [
            "0": [
                Coord(8, 1),
                Coord(5, 2),
                Coord(7, 3),
                Coord(4, 4),
            ],
            "A": [
                Coord(6, 5),
                Coord(8, 8),
                Coord(9, 9),
            ],
        ]

        expectNoDifference(map.antennaPositionsByFrequencies, expectedAntennasByFrequency)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day8().runPart1(with: inputPart)
        #expect(part1 == "14")
    }
}
