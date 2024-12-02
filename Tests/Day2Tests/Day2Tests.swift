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
        #expect(ValidReport(levels: [1, 2, 1]).flatMap(SafeReport.init) == nil)
        #expect(ValidReport(levels: [2, 1, 2]).flatMap(SafeReport.init) == nil)
        #expect(ValidReport(levels: [1, 2, 3]).flatMap(SafeReport.init) != nil)
        #expect(ValidReport(levels: [3, 2, 1]).flatMap(SafeReport.init) != nil)
    }

    @Test("SafeReport creation must have any two adjacent levels differ by at least one and at most three")
    func safeReportWithValidAdjacentIncrementOrDecrement() throws {
        #expect(ValidReport(levels: [1, 1, 2]).flatMap(SafeReport.init) == nil)
        #expect(ValidReport(levels: [2, 1, 1]).flatMap(SafeReport.init) == nil)
        #expect(ValidReport(levels: [1, 5, 6]).flatMap(SafeReport.init) == nil)
        #expect(ValidReport(levels: [6, 5, 1]).flatMap(SafeReport.init) == nil)
        #expect(ValidReport(levels: [1, 2, 4, 7]).flatMap(SafeReport.init) != nil)
        #expect(ValidReport(levels: [10, 7, 5, 4]).flatMap(SafeReport.init) != nil)
    }

    @Test("SafeReport creation set the levels of the given report as its own levels")
    func safeReportCopyValidReportLevels() throws {
        #expect(ValidReport(levels: [1, 2, 3]).flatMap(SafeReport.init)?.levels == [1, 2, 3])
        #expect(ValidReport(levels: [3, 2, 1]).flatMap(SafeReport.init)?.levels == [3, 2, 1])
        #expect(ValidReport(levels: [1, 2, 4, 7]).flatMap(SafeReport.init)?.levels == [1, 2, 4, 7])
        #expect(ValidReport(levels: [10, 7, 5, 4]).flatMap(SafeReport.init)?.levels == [10, 7, 5, 4])
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
}
