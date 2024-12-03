import Core
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

struct CorruptedOrMulParser: Parser {
    var body: some Parser<Substring, Mul?> {
        OneOf {
            MulParser()
            "mul(".map { _ in nil }
            Skip { PrefixUpTo("mul(") }.map { _ in nil }
            Rest().map { _ in nil }
        }
    }
}

struct AllMulParser: Parser {
    var body: some Parser<Substring, [Mul?]> {
        Many {
            CorruptedOrMulParser()
        }
    }
}

public struct Day3: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let mulList = try AllMulParser().parse(input).compactMap { $0 }
        return "\(mulList.reduce(0,+))"
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }
}
