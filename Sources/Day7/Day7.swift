import Core
import Parsing

public struct Day7: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let finalCalibrations = try generateCalibrationEquations(from: input)
        let allCombinationsOfOperatorsByOperandCount = finalCalibrations.prepareOperatorCombinations()
        let validCalibrations = try finalCalibrations.filter { calibrationEquation in
            guard
                let operatorCombinations = allCombinationsOfOperatorsByOperandCount[calibrationEquation.operandCount]
            else {
                throw Day7Error.missingOperatorCombinationForOperandCount(calibrationEquation.operandCount)
            }
            return try operatorCombinations.contains { operatorCombination in
                try calibrationEquation.isValid(using: operatorCombination)
            }
        }
        return validCalibrations.map(\.result).sum().asText()
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }

    private func generateCalibrationEquations(from input: String) throws -> [CalibrationEquation] {
        try AllCalibrationEquationParser().parse(input)
    }
}

enum Day7Error: Error, Equatable {
    case wrongOperatorCount
    case missingOperatorCombinationForOperandCount(Int)

    static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.wrongOperatorCount, .wrongOperatorCount):
            return true
        case let (.missingOperatorCombinationForOperandCount(vlhs), .missingOperatorCombinationForOperandCount(vrhs)):
            return vlhs == vrhs
        default:
            return false
        }
    }
}

struct AllCalibrationEquationParser: Parser {
    var body: some Parser<Substring, [CalibrationEquation]> {
        Many(into: [CalibrationEquation]()) { (array: inout [CalibrationEquation], equation: CalibrationEquation?) in
            if let equation { array.append(equation) }
        } element: {
            CalibrationEquationParser()
        } separator: {
            Whitespace(1, .vertical)
        }
    }
}

struct CalibrationEquationParser: Parser {
    var body: some Parser<Substring, CalibrationEquation?> {
        Parse(CalibrationEquation.init) {
            Int.parser()
            ": "
            Many {
                Int.parser()
            } separator: {
                Whitespace(.horizontal)
            }
        }
    }
}

extension Array where Element == CalibrationEquation {
    func prepareOperatorCombinations() -> [Int: Set<[Operator]>] {
        let allCombinationsOfOperandCount = Set(map(\.operandCount))
        return allCombinationsOfOperandCount.reduce(
            into: [Int: Set<[Operator]>]()
        ) { combinationByCount, operandCount in
            combinationByCount[operandCount] = Operator.allOperatorCombination(of: UInt(operandCount - 1))
        }
    }
}

struct CalibrationEquation: Equatable {
    let result: Int
    let operands: [Int]
    var operandCount: Int {
        operands.count
    }

    init?(result: Int, operands: [Int]) {
        guard operands.count >= 2 else { return nil }
        self.result = result
        self.operands = operands
    }

    func isValid(using operators: [Operator]) throws -> Bool {
        guard operators.count == operandCount - 1 else { throw Day7Error.wrongOperatorCount }
        var consumedOperands = operands
        var consumedOperators = operators
        var firstOperand = consumedOperands.removeFirst()
        while consumedOperands.isEmpty == false {
            let currentOperator = consumedOperators.removeFirst()
            let secondOperand = consumedOperands.removeFirst()
            firstOperand = currentOperator.apply(firstOperand, secondOperand)
        }
        return firstOperand == result
    }
}

enum Operator: Equatable, CaseIterable {
    case add
    case multiply

    func apply(_ a: Int, _ b: Int) -> Int {
        switch self {
        case .add:
            a + b
        case .multiply:
            a * b
        }
    }

    static func allOperatorCombination(of count: UInt) -> Set<[Self]> {
        var result: [[Self]] = [[]]
        for _ in 0 ..< count {
            result = result.flatMap { combinationOfi in
                self.allCases.map { combinationOfi + [$0] }
            }
        }
        return Set(result)
    }
}
