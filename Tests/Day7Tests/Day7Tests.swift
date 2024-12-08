import CustomDump
@testable import Day7
import Testing

struct Day7Tests {
    let inputPart = """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """

    @Test("Operator should have an add case with an apply method that adds two numbers")
    func operatorAddTest() {
        let op = Operator.add
        #expect(op.apply(5, 3) == 8)
        #expect(op.apply(10, 20) == 30)
        #expect(op.apply(-5, 3) == -2)
    }

    @Test("Operator should have a multiply case with an apply method that multiply two numbers")
    func operatorMultiplyTest() {
        let op = Operator.multiply
        #expect(op.apply(5, 3) == 15)
        #expect(op.apply(10, 20) == 200)
        #expect(op.apply(-5, 3) == -15)
    }

    @Test("Operator should have a concatenation case with an apply method that concatenate two numbers")
    func operatorConcatenationTest() {
        let op = Operator.concatenate
        #expect(op.apply(1, 12) == 112)
        #expect(op.apply(5, 3) == 53)
        #expect(op.apply(10, 20) == 1020)
        #expect(op.apply(-5, 3) == -53)
    }

    @Test("Set<Operator>.allOperatorCombination should return all possible combinations of operators for given count")
    func operatorCombinationsTest() {
        let operators: Set<Operator> = Set([.add, .multiply, .concatenate])

        let combinations1 = operators.allOperatorCombination(of: 1)
        expectNoDifference(Set(combinations1), Set([
            [.add],
            [.multiply],
            [.concatenate],
        ]))

        let combinations2 = operators.allOperatorCombination(of: 2)
        expectNoDifference(Set(combinations2), Set([
            [.add, .add],
            [.add, .multiply],
            [.add, .concatenate],
            [.multiply, .add],
            [.multiply, .multiply],
            [.multiply, .concatenate],
            [.concatenate, .add],
            [.concatenate, .multiply],
            [.concatenate, .concatenate],
        ]))

        let combinations3 = operators.allOperatorCombination(of: 3)
        expectNoDifference(Set(combinations3), Set([
            [.add, .add, .add],
            [.add, .add, .multiply],
            [.add, .add, .concatenate],
            [.add, .multiply, .add],
            [.add, .multiply, .multiply],
            [.add, .multiply, .concatenate],
            [.add, .concatenate, .add],
            [.add, .concatenate, .multiply],
            [.add, .concatenate, .concatenate],
            [.multiply, .add, .add],
            [.multiply, .add, .multiply],
            [.multiply, .add, .concatenate],
            [.multiply, .multiply, .add],
            [.multiply, .multiply, .multiply],
            [.multiply, .multiply, .concatenate],
            [.multiply, .concatenate, .add],
            [.multiply, .concatenate, .multiply],
            [.multiply, .concatenate, .concatenate],
            [.concatenate, .add, .add],
            [.concatenate, .add, .multiply],
            [.concatenate, .add, .concatenate],
            [.concatenate, .multiply, .add],
            [.concatenate, .multiply, .multiply],
            [.concatenate, .multiply, .concatenate],
            [.concatenate, .concatenate, .add],
            [.concatenate, .concatenate, .multiply],
            [.concatenate, .concatenate, .concatenate],
        ]))
    }

    @Test("A valid CalibrationEquation should have a result and at least two operands")
    func calibrationEquationCreationTest() {
        #expect(CalibrationEquation(result: 42, operands: []) == nil)
        #expect(CalibrationEquation(result: 42, operands: [12]) == nil)
        #expect(CalibrationEquation(result: 42, operands: [12, 30]) != nil)
        #expect(CalibrationEquation(result: 100, operands: [20, 30, 50]) != nil)
    }

    @Test("A valid CalibrationEquation should initialize its result and operands properties")
    func calibrationEquationInitPropsTest() {
        let equation = CalibrationEquation(result: 42, operands: [12, 30])
        #expect(equation?.result == 42)
        expectNoDifference(equation?.operands, [12, 30])

        let equation2 = CalibrationEquation(result: 100, operands: [20, 30, 50])
        #expect(equation2?.result == 100)
        expectNoDifference(equation2?.operands, [20, 30, 50])
    }

    @Test("A CalibrationEquation should have an operandCount property that returns the count of operands")
    func calibrationEquationOperandCountTest() {
        let equation = CalibrationEquation(result: 42, operands: [12, 30])
        #expect(equation?.operandCount == 2)

        let equation2 = CalibrationEquation(result: 100, operands: [20, 30, 50])
        #expect(equation2?.operandCount == 3)
    }

    @Test("CalibrationEquation.isValid(using:) should throw wrongOperatorCount if operations count is not equal to operandCount - 1")
    func calibrationEquationIsValidOperationCountTest() throws {
        let equation = CalibrationEquation(result: 42, operands: [12, 30])!
        let equation2 = CalibrationEquation(result: 100, operands: [20, 30, 50])!

        // Too few operations
        #expect(throws: Day7Error.wrongOperatorCount) {
            try equation.isValid(using: [])
        }
        #expect(throws: Day7Error.wrongOperatorCount) {
            try equation2.isValid(using: [.add])
        }

        // Too many operations
        #expect(throws: Day7Error.wrongOperatorCount) {
            try equation.isValid(using: [.add, .add])
        }
        #expect(throws: Day7Error.wrongOperatorCount) {
            try equation2.isValid(using: [.add, .add, .add])
        }
    }

    @Test("CalibrationEquation.isValid should return true if operators applied left-to-right without precedence rules equal the result")
    func calibrationEquationIsValidOperationsTest() throws {
        let equation = CalibrationEquation(result: 50, operands: [2, 3, 10])!

        #expect(try equation.isValid(using: [.add, .multiply]) == true)
        #expect(try equation.isValid(using: [.add, .add]) == false)

        let equation2 = CalibrationEquation(result: 100, operands: [5, 10, 2])!
        #expect(try equation2.isValid(using: [.multiply, .multiply]) == true)
        #expect(try equation2.isValid(using: [.add, .multiply]) == false)

        let equation3 = CalibrationEquation(result: 25, operands: [5, 10, 10])!
        #expect(try equation3.isValid(using: [.add, .add]) == true)
        #expect(try equation3.isValid(using: [.multiply, .add]) == false)

        let equation4 = CalibrationEquation(result: 510, operands: [5, 10])!
        #expect(try equation4.isValid(using: [.concatenate]) == true)
        #expect(try equation4.isValid(using: [.multiply]) == false)
    }

    @Test("Array<CalibrationEquation>.prepareOperatorCombinations() should return all operator combinations for each operandCount")
    func prepareOperatorCombinationsTest() throws {
        let equations = try [
            #require(CalibrationEquation(result: 42, operands: [12, 30])),
            #require(CalibrationEquation(result: 100, operands: [20, 30, 50])),
            #require(CalibrationEquation(result: 25, operands: [5, 10, 10])),
        ]

        let combinations = equations.prepareOperatorCombinations(for: Set([.add, .multiply]))

        // Should have entries for operandCounts 2 and 3
        #expect(combinations.keys.sorted() == [2, 3])

        // For 2 operands (1 operator), should have all possible single operators
        let twoOperandCombos = try #require(combinations[2])
        #expect(twoOperandCombos.count == 2) // add and multiply
        #expect(twoOperandCombos.contains([.add]))
        #expect(twoOperandCombos.contains([.multiply]))

        // For 3 operands (2 operators), should have all possible operator pairs
        let threeOperandCombos = try #require(combinations[3])
        #expect(threeOperandCombos.count == 4) // add-add, add-multiply, multiply-add, multiply-multiply
        #expect(threeOperandCombos.contains([.add, .add]))
        #expect(threeOperandCombos.contains([.add, .multiply]))
        #expect(threeOperandCombos.contains([.multiply, .add]))
        #expect(threeOperandCombos.contains([.multiply, .multiply]))
    }

    @Test("CalibrationEquationParser should parse input strings into CalibrationEquations")
    func calibrationEquationParserTest() throws {
        var input1: Substring = "190: 10 19"[...]
        var input2: Substring = "100: 5 10 2"[...]

        try expectNoDifference(
            CalibrationEquationParser().parse(&input1),
            #require(CalibrationEquation(result: 190, operands: [10, 19]))
        )
        expectNoDifference(input1, "")

        try expectNoDifference(
            CalibrationEquationParser().parse(&input2),
            #require(CalibrationEquation(result: 100, operands: [5, 10, 2]))
        )
        expectNoDifference(input2, "")
    }

    @Test("AllCalibrationEquationParser should parse multiple equations separated by newlines")
    func allCalibrationEquationParserTest() throws {
        var input: Substring = """
        190: 10 19
        100: 5 10 2
        42: 6 7
        """[...]

        let expectedEquations = try [
            #require(CalibrationEquation(result: 190, operands: [10, 19])),
            #require(CalibrationEquation(result: 100, operands: [5, 10, 2])),
            #require(CalibrationEquation(result: 42, operands: [6, 7])),
        ]

        try expectNoDifference(
            AllCalibrationEquationParser().parse(&input),
            expectedEquations
        )
        expectNoDifference(input, "")
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day7().runPart1(with: inputPart)
        #expect(part1 == "3749")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day7().runPart2(with: inputPart)
        #expect(part2 == "11387")
    }
}
