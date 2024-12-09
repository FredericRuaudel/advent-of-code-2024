import Core

public class Day6: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let lab = try reconLab(from: input)
        try lab.observeGuardPatrol()
        return lab.patrolVisitReport.count.asText()
    }

    public func runPart2(with input: String) throws -> String {
        let lab = try reconLab(from: input)
        let patrolSimulator = PatrolSimulator(lab: lab)
        let infiniteLoopObstacles = try patrolSimulator.findAllInfiniteLoopObstacles()
        return infiniteLoopObstacles.count.asText()
    }

    func reconLab(from input: String) throws -> Lab {
        let lines = input.split(separator: "\n")
        let height: Int = lines.count
        var obstacles: [Coord] = []
        var labGuard: Guard?
        var width = 0
        for (y, line) in lines.enumerated() {
            width = line.count
            for (x, character) in line.enumerated() {
                if character == "#" {
                    obstacles.append(Coord(x, y))
                } else if character == "^" {
                    labGuard = Guard(position: Coord(x, y), heading: .north)
                }
            }
        }

        guard let labGuard else { throw Day6Error.noGuardFound }
        guard let labMap = Map(width: width, height: height, obstacles: obstacles) else { throw Day6Error.invalidMapData }
        guard let lab = Lab(labMap: labMap, labGuard: labGuard) else { throw Day6Error.guardNotInMap }

        return lab
    }
}

enum Day6Error: Error {
    case guardNotInMap
    case infiniteLoopPatrol
    case invalidMapData
    case noGuardFound
}

class PatrolSimulator {
    let lab: Lab

    init(lab: Lab) {
        self.lab = lab
    }

    func findAllInfiniteLoopObstacles() throws -> Set<Coord> {
        let guardInitialPosition = lab.labGuard.position
        let guardInitialHeading = lab.labGuard.heading
        try lab.observeGuardPatrol()
        let allVisitedPositions = lab.patrolVisitReport.filter { $0 != guardInitialPosition }
        return Set(
            allVisitedPositions.filter { visitedPosition in
                let mapWithNewObstacle = currentMapWithNewObstacle(at: visitedPosition)
                var virtualGuard = Guard(position: guardInitialPosition, heading: guardInitialHeading)
                do {
                    try virtualGuard.patrol(on: mapWithNewObstacle)
                    return false
                } catch {
                    return (error as? Day6Error) == .infiniteLoopPatrol
                }
            }
        )
    }

    private func currentMapWithNewObstacle(at position: Coord) -> Map {
        Map(
            width: lab.labMap.width,
            height: lab.labMap.height,
            obstacles: Array(lab.labMap.obstacles) + [position]
        ) ?? lab.labMap
    }
}

struct Move: Equatable, Hashable {
    var position: Coord
    var heading: Direction
}

class Lab {
    let labMap: Map
    private(set) var labGuard: Guard
    var patrolVisitReport: Set<Coord> {
        Set(labGuard.patrolReport.map(\.position))
    }

    init?(labMap: Map, labGuard: Guard) {
        guard labGuard.position.isInsideArea(width: labMap.width, height: labMap.height) else { return nil }
        self.labMap = labMap
        self.labGuard = labGuard
    }

    func observeGuardPatrol() throws {
        try labGuard.patrol(on: labMap)
    }
}

struct Guard: Equatable {
    private(set) var position: Coord
    private(set) var heading: Direction
    private(set) var patrolReport: Set<Move>

    init(position: Coord, heading: Direction) {
        self.position = position
        self.heading = heading
        patrolReport = Set([Move(position: position, heading: heading)])
    }

    mutating func patrol(on map: Map) throws {
        var isPatrolling = true
        while isPatrolling {
            let nextPosition = position.heading(heading)
            switch map.move(at: nextPosition) {
            case .exitedMap:
                isPatrolling = false
            case .facedObstacle:
                heading = heading.turnRight()
            case .movedAhead:
                let nextMove = Move(position: nextPosition, heading: heading)
                if hasFeelingOfDejaVu(with: nextMove) { throw Day6Error.infiniteLoopPatrol }
                patrolReport.insert(nextMove)
                position = nextPosition
            }
        }
    }

    private func hasFeelingOfDejaVu(with move: Move) -> Bool {
        patrolReport.contains(move)
    }
}

enum Direction: Equatable, Hashable, CaseIterable {
    case north
    case east
    case south
    case west

    func turnRight() -> Self {
        switch self {
        case .north:
            return .east
        case .east:
            return .south
        case .south:
            return .west
        case .west:
            return .north
        }
    }
}

extension Coord {
    func heading(_ heading: Direction) -> Self {
        var nextX = self.x
        var nextY = self.y
        switch heading {
        case .north:
            nextY -= 1
        case .south:
            nextY += 1
        case .east:
            nextX += 1
        case .west:
            nextX -= 1
        }
        return Self(nextX, nextY)
    }
}

struct Map: Equatable {
    let width: Int
    let height: Int
    let obstacles: Set<Coord>

    init?(width: Int, height: Int, obstacles: [Coord]) {
        let uniqueObstacles = Set(obstacles)
        guard
            width >= 0 &&
            height >= 0 &&
            obstacles.count < width * height &&
            uniqueObstacles.count == obstacles.count &&
            uniqueObstacles.allSatisfy({ $0.isInsideArea(width: width, height: height) })
        else {
            return nil
        }
        self.width = width
        self.height = height
        self.obstacles = uniqueObstacles
    }

    func move(at position: Coord) -> MoveResult {
        if obstacles.contains(position) { return .facedObstacle }
        guard position.isInsideArea(width: width, height: height) else {
            return .exitedMap
        }
        return .movedAhead
    }
}

enum MoveResult: Equatable {
    case exitedMap
    case facedObstacle
    case movedAhead
}
