import CustomDump
@testable import Day5
import Testing

struct Day5Tests {
    let inputPart1 = """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """

    @Test("asText will convert a number into a String")
    func asTextTest() {
        let value = 45
        #expect(value.asText() == "45")
        #expect(23.asText() == "23")
    }

    @Test("sum will sum all numbers in an array")
    func sumTest() {
        let values = [1, 2, 3, 4]
        #expect(values.sum() == 10)
        #expect([5, 3, 2, 1].sum() == 11)
    }

    @Test("A valid SafetyReportUpdateJob should have an odd number of pages and at least 3 pages of uniq numbers")
    func safetyReportUpdateJobCreationTest() {
        #expect(SafetyReportUpdateJob(pages: []) == nil)
        #expect(SafetyReportUpdateJob(pages: [1]) == nil)
        #expect(SafetyReportUpdateJob(pages: [1, 2]) == nil)
        #expect(SafetyReportUpdateJob(pages: [1, 1, 2]) == nil)
        #expect(SafetyReportUpdateJob(pages: [1, 2, 3]) != nil)
        #expect(SafetyReportUpdateJob(pages: [1, 1, 2, 3]) != nil)
        #expect(SafetyReportUpdateJob(pages: [1, 2, 3, 4]) == nil)
        #expect(SafetyReportUpdateJob(pages: [1, 2, 3, 4, 5]) != nil)
    }

    @Test("A valid SafetyReportUpdateJob should initialize its pages property")
    func safetyReportUpdateJobInitPropTest() {
        expectNoDifference(SafetyReportUpdateJob(pages: [1, 2, 3])?.pages.elements, [1, 2, 3])
        expectNoDifference(SafetyReportUpdateJob(pages: [1, 2, 3, 2])?.pages.elements, [1, 2, 3])
        expectNoDifference(SafetyReportUpdateJob(pages: [1, 2, 3, 4, 5])?.pages.elements, [1, 2, 3, 4, 5])
    }

    @Test("A valid SafetyReportUpdateJob should have a property returning its middle page number")
    func safetyReportUpdateJobMiddlePageTest() {
        #expect(SafetyReportUpdateJob(pages: [1, 2, 3])?.middlePage == 2)
        #expect(SafetyReportUpdateJob(pages: [1, 2, 3, 4, 5])?.middlePage == 3)
    }

    @Test("A valid PageDependencyRule should have a list of preceding pages that has at least one page and not the target one")
    func pageDependencyRuleCreationTest() {
        #expect(PageDependencyRule(targetPage: 10, precedingPages: []) == nil)
        #expect(PageDependencyRule(targetPage: 10, precedingPages: [10]) == nil)
        #expect(PageDependencyRule(targetPage: 10, precedingPages: [1]) != nil)
        #expect(PageDependencyRule(targetPage: 10, precedingPages: [1, 2]) != nil)
    }

    @Test("A valid PageDependencyRule should have a targetPage property set")
    func pageDependencyRuleTargetPagePropTest() {
        #expect(PageDependencyRule(targetPage: 10, precedingPages: [1])?.targetPage == 10)
        #expect(PageDependencyRule(targetPage: 11, precedingPages: [2])?.targetPage == 11)
    }

    @Test("A valid PageDependencyRule should have a set of preceding pages that are uniq in a precedingPages property")
    func pageDependencyRulePrecedingPagesPropTest() {
        expectNoDifference(PageDependencyRule(targetPage: 10, precedingPages: [1, 2])?.precedingPages, Set([1, 2]))
        expectNoDifference(PageDependencyRule(targetPage: 10, precedingPages: [1, 1, 2])?.precedingPages, Set([1, 2]))
    }

    @Test("A PageDependencyRule should be identified by its targetPage")
    func pageDependencyRuleIdentityTest() {
        #expect(PageDependencyRule(targetPage: 10, precedingPages: [1])?.id == 10)
        #expect(PageDependencyRule(targetPage: 12, precedingPages: [1])?.id == 12)
    }

    @Test("A SafetyReportUpdateJob has a validate method that use a list of PageDependencyRules to check its page ordering")
    func safetyReportUpdateJobValidateTest() throws {
        #expect(try SafetyReportUpdateJob(pages: [75, 47, 61, 53, 29])?.validate(with: Set([
            #require(PageDependencyRule(targetPage: 61, precedingPages: [97, 47, 75])),
            #require(PageDependencyRule(targetPage: 13, precedingPages: [97, 61, 29, 4775, 53])),
            #require(PageDependencyRule(targetPage: 29, precedingPages: [75, 97, 53, 61, 47])),
        ])) == true)
        #expect(try SafetyReportUpdateJob(pages: [61, 13, 29])?.validate(with: Set([
            #require(PageDependencyRule(targetPage: 61, precedingPages: [97, 47, 75])),
            #require(PageDependencyRule(targetPage: 13, precedingPages: [97, 61, 29, 4775, 53])),
            #require(PageDependencyRule(targetPage: 29, precedingPages: [75, 97, 53, 61, 47])),
        ])) == false)
    }

    @Test("fetchUpdates validatedBy should returns all valid SafetyReportUpdateJobs using a list of PageDependencyRule as validator")
    func fetchUpdatesTest() throws {
        let safetyReportUpdateJobs1 = try [
            #require(SafetyReportUpdateJob(pages: [75, 47, 61, 53, 29])),
            #require(SafetyReportUpdateJob(pages: [61, 13, 29])),
        ]
        let safetyReportUpdateJobs2 = try [
            #require(SafetyReportUpdateJob(pages: [11, 97, 61, 13, 29])),
            #require(SafetyReportUpdateJob(pages: [97, 61, 53, 29, 13])),
        ]
        let pageDependencyRules = try Set([
            #require(PageDependencyRule(targetPage: 61, precedingPages: [97, 47, 75])),
            #require(PageDependencyRule(targetPage: 13, precedingPages: [97, 61, 29, 47, 75, 53])),
            #require(PageDependencyRule(targetPage: 29, precedingPages: [75, 97, 53, 61, 47])),
        ])
        try expectNoDifference(safetyReportUpdateJobs1.fetchUpdates(validatedBy: pageDependencyRules), [
            #require(SafetyReportUpdateJob(pages: [75, 47, 61, 53, 29])),
        ])
        try expectNoDifference(safetyReportUpdateJobs2.fetchUpdates(validatedBy: pageDependencyRules), [
            #require(SafetyReportUpdateJob(pages: [97, 61, 53, 29, 13])),
        ])
    }

    @Test("A valid PageOrderingRule should have two different page numbers")
    func pageOrderingRuleCreationTest() {
        #expect(PageOrderingRule(firstPage: 1, secondPage: 1) == nil)
        #expect(PageOrderingRule(firstPage: 1, secondPage: 2) != nil)
        #expect(PageOrderingRule(firstPage: 2, secondPage: 1) != nil)
    }

    @Test("A valid PageOrderingRule should have a firstPage property to store first page number")
    func pageOrderingRuleFirstPagePropTest() {
        #expect(PageOrderingRule(firstPage: 1, secondPage: 2)?.firstPage == 1)
        #expect(PageOrderingRule(firstPage: 3, secondPage: 2)?.firstPage == 3)
    }

    @Test("A valid PageOrderingRule should have a secondPage property to store second page number")
    func pageOrderingRuleSecondPagePropTest() {
        #expect(PageOrderingRule(firstPage: 2, secondPage: 1)?.secondPage == 1)
        #expect(PageOrderingRule(firstPage: 2, secondPage: 3)?.secondPage == 3)
    }

    @Test("convertToPageDependencyRules method should convert a list of PageOrderingRules into a list of PageDependencyRules")
    func convertToPageDependencyRulesTest() throws {
        let pageOrderingRules1 = try [
            #require(PageOrderingRule(firstPage: 47, secondPage: 53)),
            #require(PageOrderingRule(firstPage: 75, secondPage: 53)),
            #require(PageOrderingRule(firstPage: 51, secondPage: 53)),
            #require(PageOrderingRule(firstPage: 97, secondPage: 53)),
        ]
        let pageOrderingRules2 = try [
            #require(PageOrderingRule(firstPage: 97, secondPage: 13)),
            #require(PageOrderingRule(firstPage: 61, secondPage: 13)),
            #require(PageOrderingRule(firstPage: 29, secondPage: 13)),
            #require(PageOrderingRule(firstPage: 97, secondPage: 61)),
            #require(PageOrderingRule(firstPage: 47, secondPage: 61)),
        ]
        try expectNoDifference(pageOrderingRules1.convertToPageDependencyRules(), Set([
            #require(PageDependencyRule(targetPage: 53, precedingPages: [47, 75, 51, 97])),
        ]))
        try expectNoDifference(pageOrderingRules2.convertToPageDependencyRules(), Set([
            #require(PageDependencyRule(targetPage: 13, precedingPages: [97, 61, 29])),
            #require(PageDependencyRule(targetPage: 61, precedingPages: [97, 47])),
        ]))
    }

    @Test("A valid DailyPrintingWork should have at least on PageOrderingRule and one SafetyReportUpdateJob")
    func dailyPrintingWorkCreationTest() throws {
        let pageOrderingRule = try #require(PageOrderingRule(firstPage: 47, secondPage: 53))
        let safetyReportUpdateJob = try #require(SafetyReportUpdateJob(pages: [1, 2, 3]))
        #expect(DailyPrintingWork(pageOrderingRules: [], safetyReportUpdateJobs: []) == nil)
        #expect(DailyPrintingWork(pageOrderingRules: [pageOrderingRule], safetyReportUpdateJobs: [safetyReportUpdateJob]) != nil)
    }

    @Test("A valid DailyPrintingWork should have a pageOrderingRules property")
    func dailyPrintingWorkPageOrderingRulesPropTest() throws {
        let pageOrderingRule1 = try #require(PageOrderingRule(firstPage: 47, secondPage: 53))
        let pageOrderingRule2 = try #require(PageOrderingRule(firstPage: 16, secondPage: 97))
        let safetyReportUpdateJob = try #require(SafetyReportUpdateJob(pages: [1, 2, 3]))
        expectNoDifference(
            DailyPrintingWork(
                pageOrderingRules: [pageOrderingRule1, pageOrderingRule2],
                safetyReportUpdateJobs: [safetyReportUpdateJob]
            )?.pageOrderingRules,
            [
                pageOrderingRule1,
                pageOrderingRule2,
            ]
        )
    }

    @Test("A valid DailyPrintingWork should have a safetyReportUpdateJobs property")
    func dailyPrintingWorkSafetyReportUpdateJobsPropTest() throws {
        let pageOrderingRule = try #require(PageOrderingRule(firstPage: 47, secondPage: 53))
        let safetyReportUpdateJob1 = try #require(SafetyReportUpdateJob(pages: [1, 2, 3]))
        let safetyReportUpdateJob2 = try #require(SafetyReportUpdateJob(pages: [2, 3, 5, 7, 4]))
        expectNoDifference(
            DailyPrintingWork(
                pageOrderingRules: [pageOrderingRule],
                safetyReportUpdateJobs: [safetyReportUpdateJob1, safetyReportUpdateJob2]
            )?.safetyReportUpdateJobs,
            [
                safetyReportUpdateJob1,
                safetyReportUpdateJob2,
            ]
        )
    }

    @Test("middlePages prop should return all middle pages of an array of SafetyReportUpdateJobs")
    func middlePagesTest() throws {
        let safetyReportUpdateJobs = try [
            #require(SafetyReportUpdateJob(pages: [1, 2, 3])),
            #require(SafetyReportUpdateJob(pages: [2, 3, 5, 7, 4])),
        ]
        expectNoDifference(safetyReportUpdateJobs.middlePages, [2, 5])
    }

    @Test("PageOrderingRuleParser should parse one rule")
    func pageOrderingRuleParserTest() throws {
        try expectNoDifference(PageOrderingRuleParser().parse("47|53"), PageOrderingRule(firstPage: 47, secondPage: 53))
        try expectNoDifference(PageOrderingRuleParser().parse("97|13"), PageOrderingRule(firstPage: 97, secondPage: 13))
    }

    @Test("allPageOrderingRuleParser should parse a list of PageOrderingRules")
    func allPageOrderingRuleParserTest() throws {
        var input: Substring = """
        97|75
        47|61
        75|61
        """
        try expectNoDifference(allPageOrderingRuleParser.parse(&input), [
            #require(PageOrderingRule(firstPage: 97, secondPage: 75)),
            #require(PageOrderingRule(firstPage: 47, secondPage: 61)),
            #require(PageOrderingRule(firstPage: 75, secondPage: 61)),
        ])
        expectNoDifference(input, "")
    }

    @Test("SafetyReportUpdateJobParser should parse one job")
    func safetyReportUpdateJobParserTest() throws {
        try expectNoDifference(SafetyReportUpdateJobParser().parse("34,45,56"), SafetyReportUpdateJob(pages: [34, 45, 56]))
    }

    @Test("allSafetyReportUpdateJobParser should parse a list of SafetyReportUpdateJobs")
    func allSafetyReportUpdateJobParserTest() throws {
        var input: Substring = """
        61,13,29
        97,13,75,29,47
        """
        try expectNoDifference(allSafetyReportUpdateJobParser.parse(&input), [
            #require(SafetyReportUpdateJob(pages: [61, 13, 29])),
            #require(SafetyReportUpdateJob(pages: [97, 13, 75, 29, 47])),
        ])
        expectNoDifference(input, "")
    }

    @Test("DailyPrintingWorkParser should parse a DailyPrintingWork")
    func dailyPrintingWorkParserTest() throws {
        var input: Substring = inputPart1[...]
        try expectNoDifference(DailyPrintingWorkParser().parse(&input), DailyPrintingWork(
            pageOrderingRules: [
                #require(PageOrderingRule(firstPage: 47, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 61)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 47)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 61, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 29, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 53, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 61, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 61, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 47, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 47)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 75)),
                #require(PageOrderingRule(firstPage: 47, secondPage: 61)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 61)),
                #require(PageOrderingRule(firstPage: 47, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 53, secondPage: 13)),
            ],
            safetyReportUpdateJobs: [
                #require(SafetyReportUpdateJob(pages: [75, 47, 61, 53, 29])),
                #require(SafetyReportUpdateJob(pages: [97, 61, 53, 29, 13])),
                #require(SafetyReportUpdateJob(pages: [75, 29, 13])),
                #require(SafetyReportUpdateJob(pages: [75, 97, 47, 61, 53])),
                #require(SafetyReportUpdateJob(pages: [61, 13, 29])),
                #require(SafetyReportUpdateJob(pages: [97, 13, 75, 29, 47])),
            ]
        ))
        expectNoDifference(input, "")
    }

    @Test("fetchDailyWork should return a DailyPrintingWork from given input")
    func fetchDailyWorkTest() throws {
        try expectNoDifference(Day5().fetchDailyWork(from: inputPart1), DailyPrintingWork(
            pageOrderingRules: [
                #require(PageOrderingRule(firstPage: 47, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 61)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 47)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 61, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 29, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 53, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 61, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 53)),
                #require(PageOrderingRule(firstPage: 61, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 47, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 47)),
                #require(PageOrderingRule(firstPage: 97, secondPage: 75)),
                #require(PageOrderingRule(firstPage: 47, secondPage: 61)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 61)),
                #require(PageOrderingRule(firstPage: 47, secondPage: 29)),
                #require(PageOrderingRule(firstPage: 75, secondPage: 13)),
                #require(PageOrderingRule(firstPage: 53, secondPage: 13)),
            ],
            safetyReportUpdateJobs: [
                #require(SafetyReportUpdateJob(pages: [75, 47, 61, 53, 29])),
                #require(SafetyReportUpdateJob(pages: [97, 61, 53, 29, 13])),
                #require(SafetyReportUpdateJob(pages: [75, 29, 13])),
                #require(SafetyReportUpdateJob(pages: [75, 97, 47, 61, 53])),
                #require(SafetyReportUpdateJob(pages: [61, 13, 29])),
                #require(SafetyReportUpdateJob(pages: [97, 13, 75, 29, 47])),
            ]
        ))
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day5().runPart1(with: inputPart1)
        #expect(part1 == "143")
    }

    @Test("fetchUpdates invalidatedBy should return all SafetyReportUpdateJobs invalid according to given PageDependencyRules")
    func fetchUpdateInvalidTest() throws {
        let safetyReportUpdateJobs1 = try [
            #require(SafetyReportUpdateJob(pages: [75, 47, 61, 53, 29])),
            #require(SafetyReportUpdateJob(pages: [61, 13, 29])),
        ]
        let safetyReportUpdateJobs2 = try [
            #require(SafetyReportUpdateJob(pages: [11, 97, 61, 13, 29])),
            #require(SafetyReportUpdateJob(pages: [97, 61, 53, 29, 13])),
        ]
        let pageDependencyRules = try Set([
            #require(PageDependencyRule(targetPage: 61, precedingPages: [97, 47, 75])),
            #require(PageDependencyRule(targetPage: 13, precedingPages: [97, 61, 29, 47, 75, 53])),
            #require(PageDependencyRule(targetPage: 29, precedingPages: [75, 97, 53, 61, 47])),
        ])
        try expectNoDifference(safetyReportUpdateJobs1.fetchUpdates(invalidatedBy: pageDependencyRules), [
            #require(SafetyReportUpdateJob(pages: [61, 13, 29])),
        ])
        try expectNoDifference(safetyReportUpdateJobs2.fetchUpdates(invalidatedBy: pageDependencyRules), [
            #require(SafetyReportUpdateJob(pages: [11, 97, 61, 13, 29])),
        ])
    }

    @Test("fixed method return the invalid SafetyReportUpdateJobs fixed using given PageDependencyRules")
    func safetyReportUpdateJobFixedTest() throws {
        let pageDependencyRules = try Set([
            #require(PageDependencyRule(targetPage: 61, precedingPages: [97, 47, 75])),
            #require(PageDependencyRule(targetPage: 13, precedingPages: [97, 61, 29, 47, 75, 53])),
            #require(PageDependencyRule(targetPage: 29, precedingPages: [75, 97, 53, 61, 47])),
            #require(PageDependencyRule(targetPage: 75, precedingPages: [97])),
            #require(PageDependencyRule(targetPage: 47, precedingPages: [97, 75])),
            #require(PageDependencyRule(targetPage: 53, precedingPages: [47, 75, 61, 97])),
        ])
        let safetyReportUpdateJob1 = try #require(SafetyReportUpdateJob(pages: [61, 13, 29]))
        let safetyReportUpdateJob2 = try #require(SafetyReportUpdateJob(pages: [75, 97, 47, 61, 53]))
        let safetyReportUpdateJob3 = try #require(SafetyReportUpdateJob(pages: [97, 13, 75, 29, 47]))
        expectNoDifference(safetyReportUpdateJob1.fixed(using: pageDependencyRules), SafetyReportUpdateJob(pages: [61, 29, 13]))
        expectNoDifference(safetyReportUpdateJob2.fixed(using: pageDependencyRules), SafetyReportUpdateJob(pages: [97, 75, 47, 61, 53]))
        expectNoDifference(safetyReportUpdateJob3.fixed(using: pageDependencyRules), SafetyReportUpdateJob(pages: [97, 75, 47, 29, 13]))
    }

    @Test("fixed method return the same SafetyReportUpdateJobs if already valid")
    func safetyReportUpdateJobFixedForValidJobTest() throws {
        let pageDependencyRules = try Set([
            #require(PageDependencyRule(targetPage: 61, precedingPages: [97, 47, 75])),
            #require(PageDependencyRule(targetPage: 13, precedingPages: [97, 61, 29, 47, 75, 53])),
            #require(PageDependencyRule(targetPage: 29, precedingPages: [75, 97, 53, 61, 47])),
            #require(PageDependencyRule(targetPage: 75, precedingPages: [97])),
            #require(PageDependencyRule(targetPage: 47, precedingPages: [97, 75])),
            #require(PageDependencyRule(targetPage: 53, precedingPages: [47, 75, 61, 97])),
        ])
        let safetyReportUpdateJob1 = try #require(SafetyReportUpdateJob(pages: [61, 29, 13]))
        expectNoDifference(safetyReportUpdateJob1.fixed(using: pageDependencyRules), safetyReportUpdateJob1)
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day5().runPart2(with: inputPart1)
        #expect(part2 == "123")
    }
}
