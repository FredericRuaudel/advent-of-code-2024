import CustomDump
@testable import Day10
import Testing

struct Day10Tests {
    let inputPart = """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day10().runPart1(with: inputPart)
        #expect(part1 == "")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day10().runPart2(with: inputPart)
        #expect(part2 == "")
    }
}
