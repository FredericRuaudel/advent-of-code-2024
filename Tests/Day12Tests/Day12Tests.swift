import CustomDump
@testable import Day12
import Testing

struct Day12Tests {
    let inputPart = """
    """
    
    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day12().runPart1(with: inputPart)
        #expect(part1 == "")
    }
    
    @Test("Part2 with challenge example input") 
    func exampleInputPart2() throws {
        let part2 = try Day12().runPart2(with: inputPart)
        #expect(part2 == "")
    }
} 