import Core
import CustomDump
@testable import Day13
import Testing

struct Day13Tests {
    let inputPart = """
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400

    Button A: X+26, Y+66
    Button B: X+67, Y+21
    Prize: X=12748, Y=12176

    Button A: X+17, Y+86
    Button B: X+84, Y+37
    Prize: X=7870, Y=6450

    Button A: X+69, Y+23
    Button B: X+27, Y+71
    Prize: X=18641, Y=10279
    """

    @Test("ClawMachine init should require positive coordinates")
    func clawMachineInit() {
        // Valid coordinates - all positive
        let validMachine = ClawMachine(
            buttonAOffset: Coord(94, 34),
            buttonBOffset: Coord(22, 67),
            prizeLocation: Coord(8400, 5400)
        )
        #expect(validMachine != nil)

        // Invalid coordinates - negative X
        let negativeX = ClawMachine(
            buttonAOffset: Coord(-5, 34),
            buttonBOffset: Coord(22, 67),
            prizeLocation: Coord(8400, 5400)
        )
        #expect(negativeX == nil)

        // Invalid coordinates - negative Y
        let negativeY = ClawMachine(
            buttonAOffset: Coord(94, 34),
            buttonBOffset: Coord(22, -3),
            prizeLocation: Coord(8400, 5400)
        )
        #expect(negativeY == nil)

        // Invalid coordinates - negative prize location
        let negativePrize = ClawMachine(
            buttonAOffset: Coord(94, 34),
            buttonBOffset: Coord(22, 67),
            prizeLocation: Coord(-8400, -100)
        )
        #expect(negativePrize == nil)
    }

    @Test("ClawMachine should store init arguments in properties")
    func clawMachineProperties() {
        let buttonA = Coord(94, 34)
        let buttonB = Coord(22, 67)
        let prize = Coord(8400, 5400)

        let machine = ClawMachine(
            buttonAOffset: buttonA,
            buttonBOffset: buttonB,
            prizeLocation: prize
        )

        #expect(machine?.buttonAOffset == buttonA)
        #expect(machine?.buttonBOffset == buttonB)
        #expect(machine?.prizeLocation == prize)
    }

    @Test("ClawMachine should have a property buttonBPushCount that returns number of B push to get to prize location")
    func clawMachineButtonBPushCount() throws {
        let validMachine = try #require(
            ClawMachine(
                buttonAOffset: Coord(94, 34),
                buttonBOffset: Coord(22, 67),
                prizeLocation: Coord(8400, 5400)
            )
        )

        #expect(validMachine.buttonBPushCount == 40)

        let validMachine1 = try #require(
            ClawMachine(
                buttonAOffset: Coord(17, 86),
                buttonBOffset: Coord(84, 37),
                prizeLocation: Coord(7870, 6450)
            )
        )

        #expect(validMachine1.buttonBPushCount == 86)
    }

    @Test("ClawMachine should have a property buttonBPushCount that returns nil when there is no way to reach prize")
    func clawMachineButtonBPushCountFail() throws {
        let validMachine = try #require(
            ClawMachine(
                buttonAOffset: Coord(26, 66),
                buttonBOffset: Coord(67, 21),
                prizeLocation: Coord(12748, 12176)
            )
        )

        #expect(validMachine.buttonBPushCount == nil)
    }

    @Test("ClawMachine should have a property buttonAPushCount that returns number of A push to get to prize location")
    func clawMachineButtonAPushCount() throws {
        let validMachine = try #require(
            ClawMachine(
                buttonAOffset: Coord(94, 34),
                buttonBOffset: Coord(22, 67),
                prizeLocation: Coord(8400, 5400)
            )
        )

        #expect(validMachine.buttonAPushCount == 80)

        let validMachine1 = try #require(
            ClawMachine(
                buttonAOffset: Coord(17, 86),
                buttonBOffset: Coord(84, 37),
                prizeLocation: Coord(7870, 6450)
            )
        )

        #expect(validMachine1.buttonAPushCount == 38)
    }

    @Test("ClawMachine should have a property buttonAPushCount that returns nil when there is no way to reach prize")
    func clawMachineButtonAPushCountFail() throws {
        let validMachine = try #require(
            ClawMachine(
                buttonAOffset: Coord(26, 66),
                buttonBOffset: Coord(67, 21),
                prizeLocation: Coord(12748, 12176)
            )
        )

        #expect(validMachine.buttonAPushCount == nil)
    }

    @Test("ClawMachine should have a property tokenCost that returns 0 when no solution exists")
    func clawMachineTokenCostNoSolution() throws {
        let validMachine = try #require(
            ClawMachine(
                buttonAOffset: Coord(26, 66),
                buttonBOffset: Coord(67, 21),
                prizeLocation: Coord(12748, 12176)
            )
        )

        #expect(validMachine.tokenCost == 0)
    }

    @Test("ClawMachine should have a property tokenCost that returns 3 times A push count plus B push count")
    func clawMachineTokenCost() throws {
        let validMachine = try #require(
            ClawMachine(
                buttonAOffset: Coord(94, 34),
                buttonBOffset: Coord(22, 67),
                prizeLocation: Coord(8400, 5400)
            )
        )

        #expect(validMachine.tokenCost == 280)

        let validMachine1 = try #require(
            ClawMachine(
                buttonAOffset: Coord(17, 86),
                buttonBOffset: Coord(84, 37),
                prizeLocation: Coord(7870, 6450)
            )
        )

        #expect(validMachine1.tokenCost == 200)
    }

    @Test("OrdinateParser with X+ prefix should parse an input string that starts with 'X+' then a number")
    func ordinateParserWithXPrefixTest() throws {
        #expect(try OrdinateParser(prefix: "X+").parse("X+123") == 123)
        #expect(try OrdinateParser(prefix: "X+").parse("X+0") == 0)
        #expect(try OrdinateParser(prefix: "X+").parse("X+42") == 42)

        var input: Substring = "X+123\nother text"
        try expectNoDifference(OrdinateParser(prefix: "X+").parse(&input), 123)
        #expect(input == "\nother text")
    }

    @Test("OrdinateParser with Y+ prefix should parse an input string that starts with 'Y+' then a number")
    func ordinateParserWithYPrefixTest() throws {
        #expect(try OrdinateParser(prefix: "Y+").parse("Y+123") == 123)
        #expect(try OrdinateParser(prefix: "Y+").parse("Y+0") == 0)
        #expect(try OrdinateParser(prefix: "Y+").parse("Y+42") == 42)

        var input: Substring = "Y+123\nother text"
        try expectNoDifference(OrdinateParser(prefix: "Y+").parse(&input), 123)
        #expect(input == "\nother text")
    }

    @Test("OffsetParser should parse coordinates in X+n, Y+n format")
    func offserParserTest() throws {
        #expect(try OffsetParser().parse("X+123, Y+456") == Coord(123, 456))
        #expect(try OffsetParser().parse("X+0, Y+0") == Coord(0, 0))
        #expect(try OffsetParser().parse("X+42, Y+99") == Coord(42, 99))

        var input: Substring = "X+123, Y+456\nother text"
        try expectNoDifference(OffsetParser().parse(&input), Coord(123, 456))
        #expect(input == "\nother text")
    }

    @Test("CoordParser should parse coordinates in X=n, Y=n format")
    func coordParserTest() throws {
        #expect(try CoordParser().parse("X=123, Y=456") == Coord(123, 456))
        #expect(try CoordParser().parse("X=0, Y=0") == Coord(0, 0))
        #expect(try CoordParser().parse("X=42, Y=99") == Coord(42, 99))

        var input: Substring = "X=123, Y=456\nother text"
        try expectNoDifference(CoordParser().parse(&input), Coord(123, 456))
        #expect(input == "\nother text")
    }

    @Test("ClawMachineParser should parse input format into ClawMachine")
    func clawMachineParserTest() throws {
        let input = """
        Button A: X+94, Y+34
        Button B: X+22, Y+67
        Prize: X=8400, Y=5400
        """

        let expected = ClawMachine(
            buttonAOffset: Coord(94, 34),
            buttonBOffset: Coord(22, 67),
            prizeLocation: Coord(8400, 5400)
        )

        let parsed = try ClawMachineParser().parse(input)
        expectNoDifference(parsed, expected)
    }

    @Test("AllClawMachineParser should parse multiple ClawMachine objects separated by double newlines")
    func allClawMachineParserTest() throws {
        let input = """
        Button A: X+94, Y+34
        Button B: X+22, Y+67
        Prize: X=8400, Y=5400

        Button A: X+42, Y+12
        Button B: X+15, Y+45
        Prize: X=1200, Y=900

        Button A: X+33, Y+89
        Button B: X+67, Y+21
        Prize: X=4500, Y=3200
        """

        let expected = [
            ClawMachine(
                buttonAOffset: Coord(94, 34),
                buttonBOffset: Coord(22, 67),
                prizeLocation: Coord(8400, 5400)
            ),
            ClawMachine(
                buttonAOffset: Coord(42, 12),
                buttonBOffset: Coord(15, 45),
                prizeLocation: Coord(1200, 900)
            ),
            ClawMachine(
                buttonAOffset: Coord(33, 89),
                buttonBOffset: Coord(67, 21),
                prizeLocation: Coord(4500, 3200)
            ),
        ]

        let parsed = try AllClawMachineParser().parse(input)
        expectNoDifference(parsed, expected)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day13().runPart1(with: inputPart)
        #expect(part1 == "480")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day13().runPart2(with: inputPart)
        #expect(part2 == "")
    }
}
