import Core
import Parsing

struct ValidReport: Equatable {
    var levels: [Int]

    init?(levels: [Int]) {
        guard levels.count > 2 else { return nil }
        self.levels = levels
    }
}

struct SafeReport: Equatable {
    var levels: [Int]

    init?(from report: ValidReport) {
        let levels = report.levels
        guard
            levels.sorted() == levels ||
            levels.sorted().reversed() == levels
        else {
            return nil
        }

        let allLevelsByAdjacentPair = zip(levels.dropLast(), levels.dropFirst()).map { $0 }

        let allSafeLevelsByAdjacentPair = allLevelsByAdjacentPair.filter { first, second in
            let difference = abs(first - second)
            return difference >= 1 && difference <= 3
        }

        guard allLevelsByAdjacentPair.count == allSafeLevelsByAdjacentPair.count else { return nil }
        self.levels = report.levels
    }
}

struct ValidReportParser: Parser {
    var body: some Parser<Substring, ValidReport?> {
        Parse(ValidReport.init) {
            Many {
                Int.parser()
            } separator: {
                " "
            }
        }
    }
}

struct AllValidReportParser: Parser {
    var body: some Parser<Substring, [ValidReport?]> {
        Many {
            ValidReportParser()
        } separator: {
            "\n"
        }
    }
}

public struct Day2: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let allValidReports = try AllValidReportParser().parse(input).compactMap { $0 }

        return "\(allValidReports.compactMap { SafeReport(from: $0) }.count)"
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }
}
