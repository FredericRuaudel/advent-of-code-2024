import CustomDump
@testable import Day3
import Testing

struct Day3Tests {
    let input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

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

    @Test("CorruptedOrMulParser should parse corrupted values followed by the start of a mul")
    func corruptedOrMulParserCorruptedAndMul() throws {
        var input: Substring = "%&mul[3,7]!@^do_not_mul("
        try expectNoDifference(CorruptedOrMulParser().parse(&input), nil)
    }

    @Test("CorruptedOrMulParser should parse an invalid mul and parens prefix if not a valid mul")
    func corruptedOrMulParserInvalidMulPrefix() throws {
        var input: Substring = "mul(123,123]"
        try expectNoDifference(CorruptedOrMulParser().parse(&input), nil)
    }

    @Test("CorruptedOrMulParser should parse corrupted value starting with an invalid mul")
    func corruptedOrMulParserCorruptedMul() throws {
        try expectNoDifference(CorruptedOrMulParser().parse("mul[123,123)"), nil)
    }

    @Test("AllMulParser should parse a long string extracting all Mul objects from it")
    func allMulParserTest() throws {
        var input1: Substring = input[...]
        try expectNoDifference(AllMulParser().parse(&input1), [nil, Mul(2,4), nil, Mul(5,5), nil, nil, nil, Mul(11,8), Mul(8, 5), nil])
        print(input1)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day3().runPart1(with: input)
        #expect(part1 == "161")
    }
}
