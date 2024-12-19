import Core
import Parsing

public final class Day14: AoCDay {
    let bathroomWidth: UInt
    let bathroomHeight: UInt

    public convenience init() {
        self.init(bathroomWidth: 101, bathroomHeight: 103)
    }

    public required init(
        bathroomWidth: UInt,
        bathroomHeight: UInt
    ) {
        self.bathroomWidth = bathroomWidth
        self.bathroomHeight = bathroomHeight
    }

    public func runPart1(with input: String) throws -> String {
        let robots = try AllRobotParser().parse(input)
        return robots.map { $0.position(after: 100, insideAreaOfWidth: bathroomWidth, height: bathroomHeight) }
            .robotCountByPosition()
            .robotCountByQuadrant(insideAreaOfWidth: bathroomWidth, height: bathroomHeight)?
            .values
            .reduce(1,*)
            .asText() ?? ""
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }
}

struct AllRobotParser: Parser {
    var body: some Parser<Substring, [Robot]> {
        Many(into: []) { (list: inout [Robot], robot: Robot?) in
            guard let robot else { return }
            list.append(robot)
        } element: {
            RobotParser()
        } separator: {
            Whitespace(1, .vertical)
        }
    }
}

struct RobotParser: Parser {
    var body: some Parser<Substring, Robot?> {
        Parse(Robot.init) {
            "p="
            CoordParser()
            Whitespace(.horizontal)
            "v="
            CoordParser()
        }
    }
}

struct CoordParser: Parser {
    var body: some Parser<Substring, Coord> {
        Parse(Coord.init) {
            Int.parser()
            ","
            Int.parser()
        }
    }
}

extension Dictionary where Key == Coord, Value == UInt {
    func robotCountByQuadrant(insideAreaOfWidth width: UInt, height: UInt) -> [Quadrant: UInt]? {
        guard width.isMultiple(of: 2) == false && height.isMultiple(of: 2) == false else { return nil }
        let (middleX, _) = width.quotientAndRemainder(dividingBy: 2)
        let (middleY, _) = height.quotientAndRemainder(dividingBy: 2)
        let quandrantCenter = Coord(Int(middleX), Int(middleY))
        return reduce(
            into: [
                .topLeft: 0,
                .topRight: 0,
                .bottomLeft: 0,
                .bottomRight: 0,
            ]
        ) { dict, element in
            let (position, count) = element
            guard let positionQuadrant = position.quadrant(withCenter: quandrantCenter) else { return }
            dict[positionQuadrant]? += count
        }
    }
}

extension Coord {
    func quadrant(withCenter center: Coord) -> Quadrant? {
        if x < center.x, y < center.y {
            .topLeft
        } else if x < center.x, y > center.y {
            .bottomLeft
        } else if x > center.x, y < center.y {
            .topRight
        } else if x > center.x, y > center.y {
            .bottomRight
        } else {
            nil
        }
    }
}

enum Quadrant: Equatable, Hashable, CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

extension Array where Element == Coord {
    func robotCountByPosition() -> [Coord: UInt] {
        reduce(into: [:]) { dict, coord in
            if dict[coord] == nil {
                dict[coord] = 0
            }
            dict[coord]? += 1
        }
    }
}

struct Robot: Equatable {
    let position: Coord
    let velocity: Coord

    init?(position: Coord, velocity: Coord) {
        guard position.x >= 0 && position.y >= 0 else { return nil }

        self.position = position
        self.velocity = velocity
    }

    func position(after duration: UInt, insideAreaOfWidth width: UInt, height: UInt) -> Coord {
        let infiniteAreaPosition = position + Int(duration) * velocity
        let coord = Coord(
            ordinate(
                insideAreaOfSize: Int(width),
                startingAt: infiniteAreaPosition.x
            ),
            ordinate(
                insideAreaOfSize: Int(height),
                startingAt: infiniteAreaPosition.y
            )
        )
        if coord == Coord(6, 7) {
            dump(self)
        }
        return coord
    }

    private func ordinate(
        insideAreaOfSize size: Int,
        startingAt startOrdinate: Int
    ) -> Int {
        let (areaSizeExceedCount, remainder) = abs(startOrdinate).quotientAndRemainder(dividingBy: size)
        if startOrdinate > 0 {
            return startOrdinate - areaSizeExceedCount * size
        } else {
            let adjustment = remainder == 0 ? 0 : 1
            return startOrdinate + (areaSizeExceedCount + adjustment) * size
        }
    }
}
