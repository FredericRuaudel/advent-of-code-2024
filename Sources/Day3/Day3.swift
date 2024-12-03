import Core
import IssueReporting
import Parsing

struct ValidNumber: Equatable {
    var value: Int

    init?(_ value: Int) {
        guard value < 1000 else { return nil }
        self.value = value
    }
}

struct Mul: Equatable {
    var lhs: ValidNumber
    var rhs: ValidNumber
    var result: Int {
        lhs.value * rhs.value
    }

    init?(_ lhs: Int, _ rhs: Int) {
        guard let vlhs = ValidNumber(lhs), let vrhs = ValidNumber(rhs) else { return nil }
        self.lhs = vlhs
        self.rhs = vrhs
    }

    static func + (_ lhs: Self, _ rhs: Self) -> Int {
        lhs.result + rhs.result
    }

    static func + (_ lhs: Int, _ rhs: Self) -> Int {
        lhs + rhs.result
    }

    static func + (_ lhs: Self, _ rhs: Int) -> Int {
        lhs.result + rhs
    }
}

enum Operation: Equatable {
    case mul(Mul)
    case `do`
    case dont
}

struct OperationProcessor: Equatable {
    var isActive = true
    var operations: [Mul] = []

    mutating func append(_ mul: Mul) {
        if isActive { operations.append(mul) }
    }

    func process() -> Int {
        operations.reduce(0, +)
    }
}

extension Array where Element == Operation {
    func toOperationProcessor() -> OperationProcessor {
        reduce(into: OperationProcessor(operations: [])) { processor, operation in
            switch operation {
            case .do:
                processor.isActive = true
            case .dont:
                processor.isActive = false
            case let .mul(mul):
                processor.append(mul)
            }
        }
    }
}

extension Mul {
    func asOperation() -> Operation {
        .mul(self)
    }
}

struct MyParsingError: Error {}

struct MyPrefixUpTo<Input: Collection, Parsers: Parser>: Parser
    where Parsers.Input == Input, Input.SubSequence == Input
{
    let parsers: Parsers

    init(@ParserBuilder<Input> _ build: () -> Parsers) {
        parsers = build()
    }

    func parse(_ input: inout Parsers.Input) throws -> Input {
        let original = input
        var currentIndex = original.startIndex
        while input.isEmpty == false {
            if let _ = try? parsers.parse(&input) {
                input = original[currentIndex...]
                return original[..<currentIndex]
            } else {
                input.removeFirst()
                currentIndex = original.index(after: currentIndex)
            }
        }
        throw MyParsingError()
    }
}

struct MulParser: Parser {
    var body: some Parser<Substring, Mul?> {
        Parse(Mul.init) {
            "mul("
            Int.parser()
            ","
            Int.parser()
            ")"
        }
    }
}

struct OperationParser: Parser {
    var body: some Parser<Substring, Operation?> {
        OneOf {
            MulParser().map { $0?.asOperation() }
            "do()".map { .do }
            "don't()".map { .dont }
        }
    }
}

struct CorruptedOrMulParser: Parser {
    var body: some Parser<Substring, Mul?> {
        OneOf {
            MulParser()
            Skip { MyPrefixUpTo { MulParser() } }.map { _ in nil }
            Rest().map { _ in nil }
        }
    }
}

struct CorruptedOrOperationParser: Parser {
    var body: some Parser<Substring, Operation?> {
        OneOf {
            OperationParser()
            Skip { MyPrefixUpTo { OperationParser() }}.map { _ in nil }
            Rest().map { _ in nil }
        }
    }
}

struct AllMulParser: Parser {
    var body: some Parser<Substring, [Mul]> {
        Many(into: [Mul]()) { (array: inout [Mul], value: Mul?) in
            if let value { array.append(value) }
        } element: {
            CorruptedOrMulParser()
        }
    }
}

struct AllOperationParser: Parser {
    var body: some Parser<Substring, [Operation]> {
        Many(into: [Operation.do]) { (array: inout [Operation], value: Operation?) in
            if let value { array.append(value) }
        } element: {
            CorruptedOrOperationParser()
        }
    }
}

public struct Day3: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let mulList = try AllMulParser().parse(input)
        return "\(mulList.reduce(0,+))"
    }

    public func runPart2(with input: String) throws -> String {
        let operationList = try AllOperationParser().parse(input)
        return "\(operationList.toOperationProcessor().process())"
    }
}
