import Core
import CustomDump
@testable import Day14
import Testing

struct Day14Tests {
    let inputPart = """
    """
    
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