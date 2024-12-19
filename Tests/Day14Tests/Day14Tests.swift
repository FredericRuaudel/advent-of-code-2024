import Core
import CustomDump
@testable import Day14
import Testing

struct Day14Tests {
    let inputPart = """
    p=0,4 v=3,-3
    p=6,3 v=-1,-3
    p=10,3 v=-1,2
    p=2,0 v=2,-1
    p=0,0 v=1,3
    p=3,0 v=-2,-2
    p=7,6 v=-1,-3
    p=3,0 v=-1,-2
    p=9,3 v=2,3
    p=7,3 v=-1,2
    p=2,4 v=2,-3
    p=9,5 v=-3,-3
    """
    let exampleWidth = 11
    let exampleHeigh = 7

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day14().runPart1(with: inputPart)
        #expect(part1 == "")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day14().runPart2(with: inputPart)
        #expect(part2 == "")
    }
}
