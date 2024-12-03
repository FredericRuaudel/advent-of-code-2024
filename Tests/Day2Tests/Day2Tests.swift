import CustomDump
@testable import Day2
import Parsing
import Testing

struct Day2Tests {
    let input = """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """

    @Test("Valid report creation has at least 3 levels")
    func validReportCreation() throws {
        #expect(ValidReport(levels: []) == nil)
        #expect(ValidReport(levels: [1]) == nil)
        #expect(ValidReport(levels: [1, 2]) == nil)
        #expect(ValidReport(levels: [1, 2, 3]) != nil)
        #expect(ValidReport(levels: [1, 2, 3, 4]) != nil)
    }

    @Test("Valid report creation set the levels to its internal property when valid")
    func validReportCreationProps() throws {
        #expect(ValidReport(levels: [])?.levels == nil)
        #expect(ValidReport(levels: [1])?.levels == nil)
        #expect(ValidReport(levels: [1, 2])?.levels == nil)
        #expect(ValidReport(levels: [1, 2, 3])?.levels == [1, 2, 3])
        #expect(ValidReport(levels: [1, 2, 3, 4])?.levels == [1, 2, 3, 4])
    }

    @Test("SafeReport creation must have all levels increasing or decreasing")
    func safeReportIncreaseOrDecrease() throws {
        #expect(ValidReport(levels: [1, 2, 1]).flatMap { SafeReport(from: $0, dampened: false) } == nil)
        #expect(ValidReport(levels: [2, 1, 2]).flatMap { SafeReport(from: $0, dampened: false) } == nil)
        #expect(ValidReport(levels: [1, 2, 3]).flatMap { SafeReport(from: $0, dampened: false) } != nil)
        #expect(ValidReport(levels: [3, 2, 1]).flatMap { SafeReport(from: $0, dampened: false) } != nil)
    }

    @Test("SafeReport creation must have any two adjacent levels differ by at least one and at most three")
    func safeReportWithValidAdjacentIncrementOrDecrement() throws {
        #expect(ValidReport(levels: [1, 1, 2]).flatMap { SafeReport(from: $0, dampened: false) } == nil)
        #expect(ValidReport(levels: [2, 1, 1]).flatMap { SafeReport(from: $0, dampened: false) } == nil)
        #expect(ValidReport(levels: [1, 5, 6]).flatMap { SafeReport(from: $0, dampened: false) } == nil)
        #expect(ValidReport(levels: [6, 5, 1]).flatMap { SafeReport(from: $0, dampened: false) } == nil)
        #expect(ValidReport(levels: [1, 2, 4, 7]).flatMap { SafeReport(from: $0, dampened: false) } != nil)
        #expect(ValidReport(levels: [10, 7, 5, 4]).flatMap { SafeReport(from: $0, dampened: false) } != nil)
    }

    @Test("SafeReport creation set the levels of the given report as its own levels")
    func safeReportCopyValidReportLevels() throws {
        #expect(ValidReport(levels: [1, 2, 3]).flatMap { SafeReport(from: $0, dampened: false) }?.levels == [1, 2, 3])
        #expect(ValidReport(levels: [3, 2, 1]).flatMap { SafeReport(from: $0, dampened: false) }?.levels == [3, 2, 1])
        #expect(ValidReport(levels: [1, 2, 4, 7]).flatMap { SafeReport(from: $0, dampened: false) }?.levels == [1, 2, 4, 7])
        #expect(ValidReport(levels: [10, 7, 5, 4]).flatMap { SafeReport(from: $0, dampened: false) }?.levels == [10, 7, 5, 4])
    }

    @Test("Parsing one valid report")
    func parsingOneValidReport() throws {
        #expect(try ValidReportParser().parse("1 2") == nil)
        #expect(try ValidReportParser().parse("1 2 3") == ValidReport(levels: [1, 2, 3]))
        #expect(try ValidReportParser().parse("1 2 3 5") == ValidReport(levels: [1, 2, 3, 5]))
        var twoLineInput: Substring = """
        1 2 3 5
        6 7 8 9
        """
        try expectNoDifference(
            ValidReportParser().parse(&twoLineInput),
            ValidReport(levels: [1, 2, 3, 5])
        )
    }

    @Test("Parsing list of valid report")
    func parsingMultilineReports() throws {
        try expectNoDifference(AllValidReportParser().parse(input), [
            ValidReport(levels: [7, 6, 4, 2, 1]),
            ValidReport(levels: [1, 2, 7, 8, 9]),
            ValidReport(levels: [9, 7, 6, 2, 1]),
            ValidReport(levels: [1, 3, 2, 4, 5]),
            ValidReport(levels: [8, 6, 4, 4, 1]),
            ValidReport(levels: [1, 3, 6, 7, 9]),
        ])
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day2().runPart1(with: input)
        #expect(part1 == "2")
    }

    @Test("Array of int is all increasing")
    func isAllIncreasingTest() throws {
        #expect([1, 2, 1].isAllIncreasing() == false)
        #expect([2, 1, 2].isAllIncreasing() == false)
        #expect([3, 2, 1].isAllIncreasing() == false)
        #expect([1, 2, 3].isAllIncreasing() == true)
    }

    @Test("Array of int is all decreasing")
    func isAllDecreasingTest() throws {
        #expect([1, 2, 1].isAllDecreasing() == false)
        #expect([2, 1, 2].isAllDecreasing() == false)
        #expect([1, 2, 3].isAllDecreasing() == false)
        #expect([3, 2, 1].isAllDecreasing() == true)
    }

    @Test("Array of int has any two adjacent levels differ by at least one and at most three")
    func hasAnyAdjacentPairBetween1and3Test() throws {
        #expect([1, 1, 2].hasAnyAdjacentPairBetween1and3() == false)
        #expect([2, 1, 1].hasAnyAdjacentPairBetween1and3() == false)
        #expect([1, 5, 6].hasAnyAdjacentPairBetween1and3() == false)
        #expect([6, 5, 1].hasAnyAdjacentPairBetween1and3() == false)
        #expect([1, 2, 4, 7].hasAnyAdjacentPairBetween1and3() == true)
        #expect([10, 7, 5, 4].hasAnyAdjacentPairBetween1and3() == true)
    }

    @Test("all array of int possible with one dropped value from original array")
    func allPossibleArraysWithOneElementDropped() throws {
        expectNoDifference([1, 2].allPossibleArraysWithOneElementDropped(), [[2], [1]])
        expectNoDifference([1, 2, 3].allPossibleArraysWithOneElementDropped(), [[2, 3], [1, 3], [1, 2]])
        expectNoDifference([1, 2, 3, 4].allPossibleArraysWithOneElementDropped(), [[2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]])
    }

    @Test("array of int is safe if allIncreasing or allDecreasing and any two adjacent levels differ by at least one and at most three")
    func isSafeArrayOfIntTest() throws {
        #expect([1, 1, 1].isSafe() == false)
        #expect([1, 5, 9].isSafe() == false)
        #expect([10, 5, 0].isSafe() == false)
        #expect([1, 2, 1].isSafe() == false)
        #expect([1, 1, 2].isSafe() == false)
        #expect([2, 1, 1].isSafe() == false)
        #expect([1, 5, 6].isSafe() == false)
        #expect([6, 5, 1].isSafe() == false)
        #expect([1, 2, 4, 7].isSafe() == true)
        #expect([10, 7, 5, 4].isSafe() == true)
    }

    @Test("SafeReport with dampened true should be safe if any level value dropped give a safe report")
    func dampenedSafeReportTest() throws {
        #expect(ValidReport(levels: [1, 1, 1]).flatMap { SafeReport(from: $0, dampened: true) } == nil)
        #expect(ValidReport(levels: [1, 5, 9]).flatMap { SafeReport(from: $0, dampened: true) } == nil)
        #expect(ValidReport(levels: [10, 5, 0]).flatMap { SafeReport(from: $0, dampened: true) } == nil)
        #expect(ValidReport(levels: [1, 2, 1]).flatMap { SafeReport(from: $0, dampened: true) } != nil)
        #expect(ValidReport(levels: [1, 1, 2]).flatMap { SafeReport(from: $0, dampened: true) } != nil)
        #expect(ValidReport(levels: [2, 1, 1]).flatMap { SafeReport(from: $0, dampened: true) } != nil)
        #expect(ValidReport(levels: [1, 5, 6]).flatMap { SafeReport(from: $0, dampened: true) } != nil)
        #expect(ValidReport(levels: [6, 5, 1]).flatMap { SafeReport(from: $0, dampened: true) } != nil)
        #expect(ValidReport(levels: [1, 2, 4, 7]).flatMap { SafeReport(from: $0, dampened: true) } != nil)
        #expect(ValidReport(levels: [10, 7, 5, 4]).flatMap { SafeReport(from: $0, dampened: true) } != nil)
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day2().runPart2(with: input)
        #expect(part2 == "4")
    }
}
