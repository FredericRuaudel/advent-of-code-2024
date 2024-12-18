import Core
import Parsing

public final class Day13: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        let clawMachines = try AllClawMachineParser().parse(input)
        return clawMachines.map(\.tokenCost).sum().asText()
    }

    public func runPart2(with input: String) throws -> String {
        let precisionUpdate = 10_000_000_000_000
        let clawMachines = try AllClawMachineParser().parse(input)
        return clawMachines.compactMap {
            ClawMachine(
                buttonAOffset: $0.buttonAOffset,
                buttonBOffset: $0.buttonBOffset,
                prizeLocation: Coord(
                    $0.prizeLocation.x + precisionUpdate,
                    $0.prizeLocation.y + precisionUpdate
                )
            )
        }.map(\.tokenCost).sum().asText()
    }
}

struct AllClawMachineParser: Parser {
    var body: some Parser<Substring, [ClawMachine]> {
        Many(into: []) { (result: inout [ClawMachine], clawMachine: ClawMachine?) in
            guard let clawMachine else { return }
            result.append(clawMachine)
        } element: {
            ClawMachineParser()
        } separator: {
            Whitespace(2, .vertical)
        }
    }
}

struct ClawMachineParser: Parser {
    var body: some Parser<Substring, ClawMachine?> {
        Parse(ClawMachine.init) {
            "Button A:"
            Whitespace(.horizontal)
            OffsetParser()
            Whitespace(1, .vertical)
            "Button B:"
            Whitespace(.horizontal)
            OffsetParser()
            Whitespace(1, .vertical)
            "Prize:"
            Whitespace(.horizontal)
            CoordParser()
        }
    }
}

struct CoordParser: Parser {
    var body: some Parser<Substring, Coord> {
        Parse(Coord.init) {
            OrdinateParser(prefix: "X=")
            ","
            Whitespace(.horizontal)
            OrdinateParser(prefix: "Y=")
        }
    }
}

struct OffsetParser: Parser {
    var body: some Parser<Substring, Coord> {
        Parse(Coord.init) {
            OrdinateParser(prefix: "X+")
            ","
            Whitespace(.horizontal)
            OrdinateParser(prefix: "Y+")
        }
    }
}

struct OrdinateParser: Parser {
    let prefix: String

    var body: some Parser<Substring, Int> {
        prefix
        Int.parser()
    }
}

struct ClawMachine: Equatable {
    let buttonAOffset: Coord
    let buttonBOffset: Coord
    let prizeLocation: Coord

    var buttonBPushCount: UInt? {
        let dividend = buttonAOffset.x * prizeLocation.y - buttonAOffset.y * prizeLocation.x
        let divisor = buttonAOffset.x * buttonBOffset.y - buttonAOffset.y * buttonBOffset.x
        let (pushCount, remainder) = dividend.quotientAndRemainder(dividingBy: divisor)
        guard remainder == 0 else { return nil }
        return UInt(pushCount)
    }

    var buttonAPushCount: UInt? {
        guard let buttonBPushCount else { return nil }
        let dividend = prizeLocation.x - buttonBOffset.x * Int(buttonBPushCount)
        let (pushCount, remainder) = dividend.quotientAndRemainder(dividingBy: buttonAOffset.x)
        guard remainder == 0 else { return nil }
        return UInt(pushCount)
    }

    var tokenCost: UInt {
        guard let buttonAPushCount, let buttonBPushCount else { return 0 }
        return 3 * buttonAPushCount + buttonBPushCount
    }

    init?(
        buttonAOffset: Coord,
        buttonBOffset: Coord,
        prizeLocation: Coord
    ) {
        guard
            buttonAOffset.x > 0 &&
            buttonAOffset.y > 0 &&
            buttonBOffset.x > 0 &&
            buttonBOffset.y > 0 &&
            prizeLocation.x > 0 &&
            prizeLocation.y > 0
        else {
            return nil
        }

        self.buttonAOffset = buttonAOffset
        self.buttonBOffset = buttonBOffset
        self.prizeLocation = prizeLocation
    }
}
