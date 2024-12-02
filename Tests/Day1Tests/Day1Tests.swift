@testable import Day1
import Testing

struct Day1Tests {
    let input = """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day1().runPart1(with: input)
        #expect(part1 == "11")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day1().runPart2(with: input)
        #expect(part2 == "31")
    }
}
