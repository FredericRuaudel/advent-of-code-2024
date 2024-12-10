import Core
import CustomDump
@testable import Day4
import Testing

struct Day4Tests {
    let inputPart1 = """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """

    let inputEast = [
        "XMAS",
        "SSSS",
        "SSSS",
        "SSSS",
    ]

    let inputSouthEast = [
        "XSSS",
        "SMSS",
        "SSAS",
        "SSSS",
    ]

    let inputSouth = [
        "XSSS",
        "MSSS",
        "ASSS",
        "SSSS",
    ]

    let inputSouthWest = [
        "SSSX",
        "SSMS",
        "SASS",
        "SSSS",
    ]

    let inputWest = [
        "SAMX",
        "SSSS",
        "SSSS",
        "SSSS",
    ]

    let inputNorthWest = [
        "SSSS",
        "SASS",
        "SSMS",
        "SSSX",
    ]

    let inputNorth = [
        "SSSS",
        "ASSS",
        "MSSS",
        "XSSS",
    ]

    let inputNorthEast = [
        "SSSS",
        "SSAS",
        "SMSS",
        "XSSS",
    ]

    let smallGrid = ["XM", "AS"]

    @Test("toCharacterGrid should return array of array of characters")
    func toCharacterGridTest() throws {
        let smallInput = """
        XM
        AS
        """
        expectNoDifference(smallInput.toCharacterGrid(), [
            "XM",
            "AS",
        ])
    }

    @Test("charAt should return a character at given coordinate in a character grid")
    func charAtTest() {
        #expect(smallGrid.char(at: Coord(0, 0)) == "X")
        #expect(smallGrid.char(at: Coord(1, 0)) == "M")
        #expect(smallGrid.char(at: Coord(0, 1)) == "A")
        #expect(smallGrid.char(at: Coord(1, 1)) == "S")
    }

    @Test("charAt should return nil if Y coordinate is out of bound")
    func charAtOutOfBoundYTest() {
        #expect(smallGrid.char(at: Coord(0, -2)) == nil)
        #expect(smallGrid.char(at: Coord(0, 2)) == nil)
    }

    @Test("charAt should return nil if X coordinate is out of bound")
    func charAtOutOfBoundXTest() {
        #expect(smallGrid.char(at: Coord(-2, 0)) == nil)
        #expect(smallGrid.char(at: Coord(2, 0)) == nil)
    }

    @Test("Direction enum has an offset property that returns a Coord representing how to move in that direction")
    func directionOffsetTest() {
        #expect(CardinalDirection.north.offset == Coord(0, -1))
        #expect(CardinalDirection.northEast.offset == Coord(1, -1))
        #expect(CardinalDirection.east.offset == Coord(1, 0))
        #expect(CardinalDirection.southEast.offset == Coord(1, 1))
        #expect(CardinalDirection.south.offset == Coord(0, 1))
        #expect(CardinalDirection.southWest.offset == Coord(-1, 1))
        #expect(CardinalDirection.west.offset == Coord(-1, 0))
        #expect(CardinalDirection.northWest.offset == Coord(-1, -1))
    }

    @Test("Adding two coordonates should add their fields")
    func coordinatesAdditivityTests() {
        expectNoDifference(Coord(1, 2) + Coord(4, 8), Coord(5, 10))
    }

    @Test("fourLetters should return the four letter from given origin and direction in grid")
    func fourLettersTests() {
        expectNoDifference(inputNorth.fourLetters(from: Coord(0, 3), towards: .north), "XMAS")
        expectNoDifference(inputNorthEast.fourLetters(from: Coord(0, 3), towards: .northEast), "XMAS")
        expectNoDifference(inputEast.fourLetters(from: Coord(0, 0), towards: .east), "XMAS")
        expectNoDifference(inputSouthEast.fourLetters(from: Coord(0, 0), towards: .southEast), "XMAS")
        expectNoDifference(inputSouth.fourLetters(from: Coord(0, 0), towards: .south), "XMAS")
        expectNoDifference(inputSouthWest.fourLetters(from: Coord(3, 0), towards: .southWest), "XMAS")
        expectNoDifference(inputWest.fourLetters(from: Coord(3, 0), towards: .west), "XMAS")
        expectNoDifference(inputNorthWest.fourLetters(from: Coord(3, 3), towards: .northWest), "XMAS")
    }

    @Test("fourLetters should return nil if there is not four letter in the given direction")
    func fourLettersFailingTest() {
        expectNoDifference(inputNorth.fourLetters(from: Coord(0, 0), towards: .northWest), nil)
    }

    @Test("allFourLetters should return all valid four letter in grid from given origin")
    func allFourLettersTest() {
        let input = [
            "XMASXMASX",
            "XMASXMASX",
            "XMASXMASX",
            "XMASXMASX",
            "XMASXMASX",
            "XMASXMASX",
            "XMASXMASX",
            "XMASXMASX",
            "XMASXMASX",
        ]
        expectNoDifference(input.allFourLetters(from: Coord(4, 4)), [
            "XXXX",
            "XMAS",
            "XMAS",
            "XMAS",
            "XXXX",
            "XSAM",
            "XSAM",
            "XSAM",
        ])
        expectNoDifference(input.allFourLetters(from: Coord(1, 1)), [
            "MASX",
            "MASX",
            "MMMM",
        ])
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day4().runPart1(with: inputPart1)
        #expect(part1 == "18")
    }

    @Test("allCoords should returns all the given character in the grid")
    func allCoordsTest() {
        let grid = [
            "XAX",
            "SXS",
            "XXM",
        ]
        expectNoDifference(grid.allCoords(of: "X"), [
            Coord(0, 0), Coord(2, 0),
            Coord(1, 1),
            Coord(0, 2), Coord(1, 2),
        ])
        expectNoDifference(grid.allCoords(of: "A"), [
            Coord(1, 0),
        ])
    }

    @Test("crossWords should give the two 3 letters words from the given center in shape of X in the grid")
    func crossWordsTest() {
        let grid = [
            "XAX",
            "SXS",
            "SXM",
        ]
        expectNoDifference(grid.crossWords(centeredAt: Coord(1, 1)), Pair(
            topLeft: "XXM",
            topRight: "XXS"
        ))
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day4().runPart2(with: inputPart1)
        #expect(part2 == "9")
    }
}
