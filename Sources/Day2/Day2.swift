import Core
import Parsing

public final class Day2: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        let allValidReports = try AllValidReportParser().parse(input).compactMap { $0 }

        return "\(allValidReports.compactMap { SafeReport(from: $0, dampened: false) }.count)"
    }

    public func runPart2(with input: String) throws -> String {
        let allValidReports = try AllValidReportParser().parse(input).compactMap { $0 }

        return "\(allValidReports.compactMap { SafeReport(from: $0, dampened: true) }.count)"
    }
}

struct ValidReport: Equatable {
    var levels: [Int]

    init?(levels: [Int]) {
        guard levels.count > 2 else { return nil }
        self.levels = levels
    }
}

struct ValidReportParser: Parser {
    var body: some Parser<Substring, ValidReport?> {
        Parse(ValidReport.init) {
            Many {
                Int.parser()
            } separator: {
                Whitespace(.horizontal)
            }
        }
    }
}

struct AllValidReportParser: Parser {
    var body: some Parser<Substring, [ValidReport?]> {
        Many {
            ValidReportParser()
        } separator: {
            Whitespace(1, .vertical)
        }
    }
}

struct SafeReport: Equatable {
    var levels: [Int]

    init?(from report: ValidReport, dampened isDampened: Bool) {
        let levels = report.levels
        guard levels.isSafe() || (isDampened && levels.allPossibleArraysWithOneElementDropped().contains { $0.isSafe() }) else {
            return nil
        }

        self.levels = report.levels
    }
}

extension Array where Element == Int {
    func isSafe() -> Bool {
        (isAllIncreasing() || isAllDecreasing()) && hasAnyAdjacentPairBetween1and3()
    }

    func isAllIncreasing() -> Bool {
        sorted() == self
    }

    func isAllDecreasing() -> Bool {
        sorted().reversed() == self
    }

    func hasAnyAdjacentPairBetween1and3() -> Bool {
        let allValuesByAdjacentPair = zip(dropLast(), dropFirst()).map { $0 }

        let allValidValuesByAdjacentPair = allValuesByAdjacentPair.filter { first, second in
            let difference = abs(first - second)
            return difference >= 1 && difference <= 3
        }

        return allValuesByAdjacentPair.count == allValidValuesByAdjacentPair.count
    }

    func allPossibleArraysWithOneElementDropped() -> [Self] {
        map { _ in self }
            .enumerated()
            .map { index, array in
                var reducedArray = array
                reducedArray.remove(at: index)
                return reducedArray
            }
    }
}
