import Core
import Foundation
import IssueReporting

public final class Day11: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        guard let me = Observer(environment: input) else { throw Day11Error.invalidInput }
        me.blink(count: 25)
        return me.visibleStones.asText()
    }

    public func runPart2(with input: String) throws -> String {
        guard let me = Observer(environment: input) else { throw Day11Error.invalidInput }
        me.blink(count: 75)
        return me.visibleStones.asText()
    }
}

enum Day11Error: Error {
    case invalidInput
}

class Observer {
    private(set) var stones: [Stone: UInt]
    var visibleStones: UInt {
        UInt(Array(stones.values).sum())
    }

    init?(environment: String) {
        let chunks = environment.split(separator: " ")
        let numbers = chunks.compactMap { UInt($0) }
        guard
            numbers.isEmpty == false,
            numbers.count == chunks.count
        else { return nil }
        stones = numbers.reduce(into: [:]) { dict, number in
            let stone = Stone(number: number)
            if dict[stone] != nil {
                dict[stone]? += 1
            } else {
                dict[stone] = 1
            }
        }
    }

    func blink(count: UInt) {
        for _ in 0 ..< count {
            stones = stones.reduce(into: [:]) { dict, element in
                let (key, value) = element
                let newStones = key.evolve().stones
                for newStone in newStones {
                    if dict[newStone] != nil {
                        dict[newStone]? += value
                    } else {
                        dict[newStone] = value
                    }
                }
            }
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

struct Stone: Equatable, Hashable {
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

extension Collection where Element == UInt {
    func merge() -> UInt {
        reversed().enumerated().reduce(into: 0) { sum, element in
            let (index, digit) = element
            sum += UInt(pow(10, Double(index))) * digit
        }
    }
}

// extension UInt {
//     func split() -> (UInt, UInt)? {
//         var quotient = self
//         var remainder: UInt = 0
//         var digitCount = 1
//         var digits = [UInt]()
//         while quotient > 9 {
//             (quotient, remainder) = quotient.quotientAndRemainder(dividingBy: 10)
//             digitCount += 1
//             digits.append(remainder)
//         }
//         guard digitCount.isMultiple(of: 2) else { return nil }
//         return (
//             digits.reversed().prefix(digitCount / 2).merge(),
//             digits.reversed().suffix(digitCount / 2).merge()
//         )
//     }
// }
