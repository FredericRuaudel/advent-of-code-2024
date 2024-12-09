import Core
import OrderedCollections
import Parsing

public class Day5: AoCDay {
    public init() {}

    struct Day5Error: Error {}

    public func runPart1(with input: String) throws -> String {
        guard let dailyPrintingWork = fetchDailyWork(from: input) else { throw Day5Error() }
        let pageDependencyRules = dailyPrintingWork.pageOrderingRules.convertToPageDependencyRules()
        let validSafetyReportUpdateJobs = dailyPrintingWork.safetyReportUpdateJobs.fetchUpdates(
            validatedBy: pageDependencyRules
        )
        return validSafetyReportUpdateJobs.middlePages.sum().asText()
    }

    public func runPart2(with input: String) throws -> String {
        guard let dailyPrintingWork = fetchDailyWork(from: input) else { throw Day5Error() }
        let pageDependencyRules = dailyPrintingWork.pageOrderingRules.convertToPageDependencyRules()
        let invalidSafetyReportUpdateJobs = dailyPrintingWork.safetyReportUpdateJobs.fetchUpdates(
            invalidatedBy: pageDependencyRules
        )
        return invalidSafetyReportUpdateJobs.map { $0.fixed(using: pageDependencyRules) }.middlePages.sum().asText()
    }

    func fetchDailyWork(from input: String) -> DailyPrintingWork? {
        try? DailyPrintingWorkParser().parse(input)
    }
}

struct DailyPrintingWorkParser: Parser {
    var body: some Parser<Substring, DailyPrintingWork?> {
        Parse(DailyPrintingWork.init) {
            allPageOrderingRuleParser
            Whitespace(1, .vertical)
            allSafetyReportUpdateJobParser
        }
    }
}

let allSafetyReportUpdateJobParser = AllParser(of: SafetyReportUpdateJobParser())

struct SafetyReportUpdateJobParser: Parser {
    var body: some Parser<Substring, SafetyReportUpdateJob?> {
        Parse(SafetyReportUpdateJob.init) {
            Many {
                Int.parser()
            } separator: {
                ","
            }
        }
    }
}

let allPageOrderingRuleParser = AllParser(of: PageOrderingRuleParser())

struct AllParser<P: Parser & Sendable, Wrapped>: Parser, Sendable
    where P.Output == Wrapped?, P.Input == Substring
{
    var parser: P
    init(of parser: P) { self.parser = parser }

    var body: some Parser<Substring, [Wrapped]> {
        Many(into: [Wrapped]()) { (array: inout [Wrapped], value: Wrapped?) in
            if let value { array.append(value) }
        } element: {
            parser
        } separator: {
            Whitespace(1, .vertical)
        }
    }
}

struct PageOrderingRuleParser: Parser {
    var body: some Parser<Substring, PageOrderingRule?> {
        Parse(PageOrderingRule.init) {
            Int.parser()
            "|"
            Int.parser()
        }
    }
}

struct DailyPrintingWork: Equatable {
    let pageOrderingRules: [PageOrderingRule]
    let safetyReportUpdateJobs: [SafetyReportUpdateJob]

    init?(pageOrderingRules: [PageOrderingRule], safetyReportUpdateJobs: [SafetyReportUpdateJob]) {
        guard pageOrderingRules.isEmpty == false && safetyReportUpdateJobs.isEmpty == false else { return nil }
        self.pageOrderingRules = pageOrderingRules
        self.safetyReportUpdateJobs = safetyReportUpdateJobs
    }
}

extension Array where Element == PageOrderingRule {
    func convertToPageDependencyRules() -> Set<PageDependencyRule> {
        let pageOrderingRulesBySecondPage: [Int: [PageOrderingRule]] = reduce(into: [:]) { dict, pageOrderingRule in
            if dict[pageOrderingRule.secondPage] == nil {
                dict[pageOrderingRule.secondPage] = []
            }
            dict[pageOrderingRule.secondPage]?.append(pageOrderingRule)
        }
        return Set(
            pageOrderingRulesBySecondPage.compactMap { secondPage, allRules in
                PageDependencyRule(targetPage: secondPage, precedingPages: allRules.map(\.firstPage))
            }
        )
    }
}

struct PageOrderingRule: Equatable {
    let firstPage: Int
    let secondPage: Int

    init?(firstPage: Int, secondPage: Int) {
        guard firstPage != secondPage else { return nil }
        self.firstPage = firstPage
        self.secondPage = secondPage
    }
}

extension Array where Element == SafetyReportUpdateJob {
    func fetchUpdates(validatedBy pageDependencyRules: Set<PageDependencyRule>) -> Self {
        filter { safetyReportUpdateJob in
            safetyReportUpdateJob.validate(with: pageDependencyRules)
        }
    }

    func fetchUpdates(invalidatedBy pageDependencyRules: Set<PageDependencyRule>) -> Self {
        filter { safetyReportUpdateJob in
            safetyReportUpdateJob.validate(with: pageDependencyRules) == false
        }
    }
}

struct PageDependencyRule: Equatable, Hashable {
    let targetPage: Int
    let precedingPages: Set<Int>

    init?(targetPage: Int, precedingPages: [Int]) {
        guard precedingPages.count > 0 && precedingPages.contains(targetPage) == false else { return nil }
        self.targetPage = targetPage
        self.precedingPages = Set(precedingPages)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(targetPage)
    }
}

extension Array where Element == SafetyReportUpdateJob {
    var middlePages: [Int] {
        map(\.middlePage)
    }
}

struct SafetyReportUpdateJob: Equatable {
    let pages: OrderedSet<Int>
    var middlePage: Int {
        let middleIndex = pages.count / 2
        return pages[middleIndex]
    }

    init?(pages: [Int]) {
        let orderedUniquePages = OrderedSet(pages)
        guard
            orderedUniquePages.count >= 3 &&
            orderedUniquePages.count.isMultiple(of: 2) == false
        else { return nil }
        self.pages = orderedUniquePages
    }

    func validate(with pageDependencyRules: Set<PageDependencyRule>) -> Bool {
        var remainingPages = pages
        var checkedPage = remainingPages.removeFirst()
        while remainingPages.isEmpty == false {
            if let checkedPageRules = pageDependencyRules.first(where: { $0.targetPage == checkedPage }),
               remainingPages.intersection(checkedPageRules.precedingPages).isEmpty == false
            {
                return false
            }
            checkedPage = remainingPages.removeFirst()
        }
        return true
    }

    func fixed(using pageDependencyRules: Set<PageDependencyRule>) -> Self {
        let fixedPages = pages.elements.sorted(by: { firstPage, secondPage in
            if let checkedPageRules = pageDependencyRules.first(where: { $0.targetPage == secondPage }),
               checkedPageRules.precedingPages.contains(firstPage)
            {
                return true
            }

            return false
        })
        return SafetyReportUpdateJob(pages: fixedPages) ?? self
    }
}

