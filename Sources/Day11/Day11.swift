import Core
import IssueReporting

public final class Day11: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        guard let me = Observer(environment: input) else { throw Day11Error.invalidInput }
        me.blink(count: 25)
        return me.visibleStones.asText()
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }
}

enum Day11Error: Error {
    case invalidInput
}

class Observer {
    private(set) var stones: [Stone]
    var visibleStones: UInt {
        UInt(stones.count)
    }

    init?(environment: String) {
        let chunks = environment.split(separator: " ")
        let numbers = chunks.compactMap { UInt($0) }
        guard
            numbers.isEmpty == false,
            numbers.count == chunks.count
        else { return nil }
        stones = numbers.map(Stone.init(number:))
    }

    func blink(count: UInt) {
        for _ in 0 ..< count {
            stones = stones.flatMap { $0.evolve().stones }
        }
    }
}

enum StoneEvolution: Equatable {
    case updated(Stone)
    case splitted(Stone, Stone)

    var stones: [Stone] {
        switch self {
        case let .updated(stone):
            return [stone]
        case let .splitted(stone1, stone2):
            return [stone1, stone2]
        }
    }
}

struct Stone: Equatable {
    let number: UInt
    var isZero: Bool {
        number == 0
    }

    init(number: UInt) {
        self.number = number
    }

    init?(splittedNumber: Substring) {
        guard let number = UInt(splittedNumber) else { return nil }
        self.number = number
    }

    func hasEvenDigitCount() -> Bool {
        String(number).count.isMultiple(of: 2)
    }

    func evolve() -> StoneEvolution {
        if isZero {
            return .updated(Stone(number: 1))
        } else if hasEvenDigitCount() {
            let stringifiedNumber = String(number)
            let numberOfDigits = stringifiedNumber.count / 2
            guard
                let stone1 = Stone(splittedNumber: stringifiedNumber.prefix(numberOfDigits)),
                let stone2 = Stone(splittedNumber: stringifiedNumber.suffix(numberOfDigits))
            else {
                reportIssue("We should be able to split \(number) at this stage")
                return .updated(self)
            }
            return .splitted(stone1, stone2)
        }
        return .updated(Stone(number: number * 2024))
    }
}
