import CustomDump
@testable import Day3
import Parsing
import Testing

struct Day3Tests {
    let inputPart1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
    let inputPart2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

    @Test("A ValidNumber is a number with 1-3 digit")
    func validNumberTest() throws {
        #expect(ValidNumber(1) != nil)
        #expect(ValidNumber(12) != nil)
        #expect(ValidNumber(123) != nil)
        #expect(ValidNumber(1234) == nil)
    }

    @Test("Mul creation must be initialized with two int number which are ValidNumbers")
    func mulCreationTest() throws {
        #expect(Mul(1234, 123) == nil)
        #expect(Mul(1, 1234) == nil)
        #expect(Mul(1, 12) != nil)
        #expect(Mul(12, 123) != nil)
        #expect(Mul(123, 1) != nil)
    }

    @Test("The Mul object has a result prop that returns the multiplication of its two other props")
    func mulResultTest() throws {
        #expect(Mul(1, 1)?.result == 1)
        #expect(Mul(12, 1)?.result == 12)
        #expect(Mul(12, 123)?.result == 12 * 123)
    }

    @Test("We can add two Mul object together")
    func mulAdditivityTest() throws {
        let vn1 = try #require(Mul(1, 1), "invalid Mul")
        let vn2 = try #require(Mul(12, 1), "invalid Mul")
        let vn3 = try #require(Mul(1, 12), "invalid Mul")
        let vn4 = try #require(Mul(12, 123), "invalid Mul")
        let vn5 = try #require(Mul(123, 1), "invalid Mul")
        #expect(vn1 + vn1 == 2)
        #expect(vn2 + vn3 == 24)
        #expect(vn4 + vn5 == 12 * 123 + 123)
    }

    @Test("We can add a Mul and an Int together")
    func mulAdditivityWithIntTest() throws {
        let vn1 = try #require(Mul(12, 123), "invalid Mul")
        let vn2 = try #require(Mul(123, 1), "invalid Mul")
        #expect(vn1 + 10 == 12 * 123 + 10)
        #expect(200 + vn2 == 323)
    }

    @Test("MulParser should parse a valid Mul")
    func mulParserTest() throws {
        #expect {
            try MulParser().parse("mul(1,)")
        } throws: { _ in true }
        #expect {
            try MulParser().parse("muL(1,1)")
        } throws: { _ in true }
        #expect {
            try MulParser().parse("mul(1,1]")
        } throws: { _ in true }
        #expect {
            try MulParser().parse("mul[1,1]")
        } throws: { _ in true }
        #expect(try MulParser().parse("mul(1,1234)") == nil)
        #expect(try MulParser().parse("mul(1234,1)") == nil)
        try expectNoDifference(MulParser().parse("mul(1,1)"), Mul(1, 1))
        try expectNoDifference(MulParser().parse("mul(1,12)"), Mul(1, 12))
        try expectNoDifference(MulParser().parse("mul(123,12)"), Mul(123, 12))
        try expectNoDifference(MulParser().parse("mul(123,123)"), Mul(123, 123))
    }

    @Test("CorruptedOrMulParser should parse a valid mul object")
    func corruptedOrMulParserParseValidMul() throws {
        try expectNoDifference(CorruptedOrMulParser().parse("mul(123,123)"), Mul(123, 123))
    }

    @Test("CorruptedOrMulParser should parse corrupted values until the start of a valid mul")
    func corruptedOrMulParserCorruptedAndMul() throws {
        var input: Substring = "%&mul[3,7]!@^do_not_mul(1,1)"
        try expectNoDifference(CorruptedOrMulParser().parse(&input), nil)
        #expect(input == "mul(1,1)")
    }

    @Test("CorruptedOrMulParser should parse everything if not a valid mul")
    func corruptedOrMulParserInvalidMulPrefix() throws {
        var input: Substring = "mul(123,123]"
        try expectNoDifference(CorruptedOrMulParser().parse(&input), nil)
        #expect(input == "")
    }

    @Test("CorruptedOrMulParser should parse corrupted value starting with an invalid mul")
    func corruptedOrMulParserCorruptedMul() throws {
        try expectNoDifference(CorruptedOrMulParser().parse("mul[123,123)"), nil)
    }

    @Test("AllMulParser should parse a long string extracting all Mul objects from it")
    func allMulParserTest() throws {
        var input: Substring = inputPart1[...]
        try expectNoDifference(AllMulParser().parse(&input), [Mul(2, 4), Mul(5, 5), Mul(11, 8), Mul(8, 5)])
        #expect(input == "")
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day3().runPart1(with: inputPart1)
        #expect(part1 == "161")
    }

    @Test("Mul can be converted into an Operation")
    func mulConversionToOperation() throws {
        let expectedMul = try #require(Mul(1, 1))
        #expect(Mul(1, 1)?.asOperation() == Operation.mul(expectedMul))
    }

    @Test("OperationParser should parse a Mul")
    func operationParserMulTest() throws {
        let expectedMul = try #require(Mul(12, 123))
        #expect(try OperationParser().parse("mul(12,123)") == Operation.mul(expectedMul))
    }

    @Test("OperationParser should parse a do()")
    func operationParserDoTest() throws {
        #expect(try OperationParser().parse("do()") == Operation.do)
    }

    @Test("OperationParser should parse a don't()")
    func operationParserDontTest() throws {
        #expect(try OperationParser().parse("don't()") == Operation.dont)
    }

    @Test("MyPrefixUpTo with simple literal parser should work as current PrefixUpTo")
    func myPrefixUpToLiteralParserTest() throws {
        var input: Substring = "blabla_match"
        #expect(try MyPrefixUpTo { "match" }.parse(&input) == "blabla_")
        #expect(input == "match")
    }

    @Test("MyPrefixUpTo with MulParser should parse giberish before a valid mul")
    func myPrefixUpToMulParserTest() throws {
        var input: Substring = "%&mul[3,7]!@^do_not_mul(5,5)"
        #expect(try MyPrefixUpTo { MulParser() }.parse(&input) == "%&mul[3,7]!@^do_not_")
        #expect(input == "mul(5,5)")
        input = "xmul(5,5)x"
        #expect(try MyPrefixUpTo { MulParser() }.parse(&input) == "x")
        #expect(input == "mul(5,5)x")
    }

    @Test("MyPrefixUpTo with MulParser should parse nothing if input start with valid mul")
    func myPrefixUpToMulParserStartWithMulTest() throws {
        var input: Substring = "mul(1,1)"
        #expect(try MyPrefixUpTo { MulParser() }.parse(&input) == "")
        #expect(input == "mul(1,1)")
    }

    @Test("CorruptedOrOperationParser should parse a valid mul object")
    func corruptedOrOperationParserParseValidMul() throws {
        try expectNoDifference(CorruptedOrOperationParser().parse("mul(123,123)"), Mul(123, 123)?.asOperation())
    }

    @Test("CorruptedOrOperationParser should parse a valid do object")
    func corruptedOrOperationParserParseValidDo() throws {
        try expectNoDifference(CorruptedOrOperationParser().parse("do()"), Operation.do)
    }

    @Test("CorruptedOrOperationParser should parse a valid don't object")
    func corruptedOrOperationParserParseValidDont() throws {
        try expectNoDifference(CorruptedOrOperationParser().parse("don't()"), Operation.dont)
    }

    @Test("CorruptedOrOperationParser should parse corrupted values until the start of a valid mul")
    func corruptedOrOperationParserCorruptedAndMul() throws {
        var input: Substring = "%&mul[3,7]!@^do_not_mul(1,1)"
        try expectNoDifference(CorruptedOrOperationParser().parse(&input), nil)
        #expect(input == "mul(1,1)")
    }

    @Test("CorruptedOrOperationParser should parse corrupted values until the start of a valid do")
    func corruptedOrOperationParserCorruptedAndDo() throws {
        var input: Substring = "%&mul[3,7]!@^do_not_do()"
        try expectNoDifference(CorruptedOrOperationParser().parse(&input), nil)
        #expect(input == "do()")
    }

    @Test("CorruptedOrOperationParser should parse corrupted values until the start of a valid don't")
    func corruptedOrOperationParserCorruptedAndDont() throws {
        var input: Substring = "%&mul[3,7]!@^don't_not_don't()"
        try expectNoDifference(CorruptedOrOperationParser().parse(&input), nil)
        #expect(input == "don't()")
    }

    @Test("CorruptedOrOperationParser should parse everything if not a valid operation")
    func corruptedOrOperationParserInvalidMulPrefix() throws {
        var input: Substring = "mul(123,123]"
        try expectNoDifference(CorruptedOrOperationParser().parse(&input), nil)
        #expect(input == "")
        input = "do(]"
        try expectNoDifference(CorruptedOrOperationParser().parse(&input), nil)
        #expect(input == "")
        input = "don't(]"
        try expectNoDifference(CorruptedOrOperationParser().parse(&input), nil)
        #expect(input == "")
    }

    @Test("CorruptedOrOperationParser should parse corrupted value starting with an invalid mul")
    func corruptedOrOperationParserCorruptedMul() throws {
        try expectNoDifference(CorruptedOrOperationParser().parse("mul[123,123)"), nil)
    }

    @Test("AllOperationParser should parse a long string extracting all Mul objects from it")
    func allOperationParserTest() throws {
        var input: Substring = inputPart2[...]
        try expectNoDifference(AllOperationParser().parse(&input), [
            Operation.do,
            Mul(2, 4)?.asOperation(),
            .dont,
            Mul(5, 5)?.asOperation(),
            Mul(11, 8)?.asOperation(),
            .do,
            Mul(8, 5)?.asOperation(),
        ])
        #expect(input == "")
    }

    @Test("OperationProcessor should be created empty and active")
    func operationProcessorCreationTest() throws {
        let processor = OperationProcessor()
        #expect(processor.isActive)
        #expect(processor.operations.isEmpty)
    }

    @Test("OperationProcessor should append a Mul to its operation if active")
    func operationProcessorAppendActiveTest() throws {
        var processor = OperationProcessor()
        let vm = try #require(Mul(2, 4))
        #expect(processor.isActive)
        processor.append(vm)
        expectNoDifference(processor.operations, [vm])
    }

    @Test("OperationProcessor should not append a Mul to its operation if not active")
    func operationProcessorAppendInactiveTest() throws {
        var processor = OperationProcessor()
        let vm = try #require(Mul(2, 4))
        processor.isActive = false
        #expect(processor.isActive == false)
        processor.append(vm)
        expectNoDifference(processor.operations, [])
    }

    @Test("An array of operation should convert to an OperationProcessor")
    func convertToOperationProcessor() throws {
        let vm1 = try #require(Mul(2, 3))
        let vm2 = try #require(Mul(2, 5))
        let vm3 = try #require(Mul(100, 1))
        let input: [Operation] = [Operation.do, .mul(vm1), Operation.dont, .mul(vm3), Operation.do, .mul(vm2)]
        expectNoDifference(input.toOperationProcessor(), OperationProcessor(isActive: true, operations: [
            vm1, vm2
        ]))
    }

    @Test("OperationProcessor should process all operation by adding all mul")
    func operationProcessorProcessTest() throws {
        let vm1 = try #require(Mul(2, 3))
        let vm2 = try #require(Mul(2, 5))
        let vm3 = try #require(Mul(100, 1))
        var processor = OperationProcessor()
        processor.append(vm1)
        processor.append(vm2)
        processor.append(vm3)
        #expect(processor.process() == 116)
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day3().runPart2(with: inputPart2)
        #expect(part2 == "48")
    }
}
