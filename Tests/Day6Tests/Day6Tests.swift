import Core
import CustomDump
@testable import Day6
import Testing

struct Day6Tests {
    let inputPart = """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """

    @Test("A valid Coord should have x and y properties")
    func coordCreationTest() {
        #expect(Coord(1, 2).x == 1)
        #expect(Coord(3, 4).x == 3)
        #expect(Coord(1, 2).y == 2)
        #expect(Coord(3, 4).y == 4)
    }

    @Test("A valid Map should be created with positive width, height and unique obstacles less than total area and inside area")
    func mapCreationTest() throws {
        #expect(Map(width: -1, height: 2, obstacles: []) == nil)
        #expect(Map(width: 1, height: -2, obstacles: []) == nil)
        #expect(Map(width: -1, height: -2, obstacles: []) == nil)
        #expect(Map(width: 0, height: 0, obstacles: []) == nil)
        #expect(Map(width: 1, height: 2, obstacles: []) != nil)
        #expect(Map(width: 10, height: 20, obstacles: []) != nil)
        #expect(Map(width: 2, height: 2, obstacles: [
            Coord(1, 1),
            Coord(1, 1),
        ]) == nil)
        #expect(Map(width: 2, height: 2, obstacles: [
            Coord(1, 1),
            Coord(1, 0),
        ]) != nil)
        #expect(Map(width: 2, height: 2, obstacles: [
            Coord(1, 1),
            Coord(1, 0),
            Coord(0, 1),
            Coord(0, 0),
        ]) == nil)
        #expect(Map(width: 2, height: 2, obstacles: [
            Coord(-1, 1),
            Coord(1, 1),
        ]) == nil)
        #expect(Map(width: 2, height: 2, obstacles: [
            Coord(1, -1),
            Coord(1, 1),
        ]) == nil)
        #expect(Map(width: 2, height: 2, obstacles: [
            Coord(2, 1),
            Coord(1, 1),
        ]) == nil)
        #expect(Map(width: 2, height: 2, obstacles: [
            Coord(1, 2),
            Coord(1, 1),
        ]) == nil)
    }

    @Test("A valid Map should have an obstacles property of type Set<Coord> initialized with obstacles argument")
    func mapObstaclesPropTest() throws {
        expectNoDifference(Map(width: 3, height: 4, obstacles: [
            Coord(1, 1),
            Coord(2, 2),
            Coord(0, 3),
        ])?.obstacles, Set([
            Coord(1, 1),
            Coord(2, 2),
            Coord(0, 3),
        ]))
        expectNoDifference(Map(width: 5, height: 5, obstacles: [
            Coord(1, 2),
            Coord(3, 4),
        ])?.obstacles, Set([
            Coord(1, 2),
            Coord(3, 4),
        ]))
    }

    @Test("A valid Map should have a width property initialized with width argument")
    func mapWidthPropTest() throws {
        #expect(Map(width: 3, height: 4, obstacles: [])?.width == 3)
        #expect(Map(width: 5, height: 2, obstacles: [])?.width == 5)
    }

    @Test("A valid Map should have a height property initialized with height argument")
    func mapHeightPropTest() throws {
        #expect(Map(width: 3, height: 4, obstacles: [])?.height == 4)
        #expect(Map(width: 5, height: 2, obstacles: [])?.height == 2)
    }

    @Test("Direction should have four cases: north, east, south and west")
    func directionCasesTest() {
        #expect(Direction.allCases.count == 4)
        #expect(Direction.allCases.contains(.north))
        #expect(Direction.allCases.contains(.east))
        #expect(Direction.allCases.contains(.south))
        #expect(Direction.allCases.contains(.west))
    }

    @Test("Direction should have a turnRight method that rotates clockwise")
    func directionTurnRightTest() {
        #expect(Direction.north.turnRight() == .east)
        #expect(Direction.east.turnRight() == .south)
        #expect(Direction.south.turnRight() == .west)
        #expect(Direction.west.turnRight() == .north)
    }

    @Test("A valid Guard should be created with a position and heading props")
    func guardCreationTest() throws {
        #expect(Guard(position: Coord(0, 0), heading: .south).position == Coord(0, 0))
        #expect(Guard(position: Coord(1, 2), heading: .north).position == Coord(1, 2))
        #expect(Guard(position: Coord(3, 4), heading: .west).heading == .west)
        #expect(Guard(position: Coord(4, 4), heading: .east).heading == .east)
    }

    @Test("A valid Guard should have a patrolReport property of type set of Move initialized with its current position and heading")
    func guardPatrolReportPropTest() throws {
        expectNoDifference(
            Guard(position: Coord(0, 0), heading: .south).patrolReport,
            Set([Move(position: Coord(0, 0), heading: .south)])
        )
        expectNoDifference(
            Guard(position: Coord(1, 2), heading: .north).patrolReport,
            Set([Move(position: Coord(1, 2), heading: .north)])
        )
    }

    @Test("Map.move method should return exitedMap when position is outside map boundaries")
    func moveExitedMapTest() throws {
        let map = try #require(Map(width: 3, height: 4, obstacles: []))
        #expect(map.move(at: Coord(-1, 0)) == .exitedMap)
        #expect(map.move(at: Coord(0, -1)) == .exitedMap)
        #expect(map.move(at: Coord(3, 0)) == .exitedMap)
        #expect(map.move(at: Coord(0, 4)) == .exitedMap)
    }

    @Test("Map.move method should return facedObstacle when position is in obstacles set")
    func moveFacedObstacleTest() throws {
        let map = try #require(Map(width: 3, height: 4, obstacles: [
            Coord(1, 1),
            Coord(2, 2),
            Coord(0, 3),
        ]))
        #expect(map.move(at: Coord(1, 1)) == .facedObstacle)
        #expect(map.move(at: Coord(2, 2)) == .facedObstacle)
        #expect(map.move(at: Coord(0, 3)) == .facedObstacle)
    }

    @Test("Map.move method should return movedAhead when position is inside map boundaries and not in obstacles set")
    func moveMovedAheadTest() throws {
        let map = try #require(Map(width: 3, height: 4, obstacles: [
            Coord(1, 1),
            Coord(2, 2),
            Coord(0, 3),
        ]))
        #expect(map.move(at: Coord(0, 0)) == .movedAhead)
        #expect(map.move(at: Coord(2, 1)) == .movedAhead)
        #expect(map.move(at: Coord(1, 3)) == .movedAhead)
    }

    @Test("Coord.heading method should return a new Coord modified according to given direction")
    func coordHeadingTest() {
        let coord = Coord(2, 3)
        #expect(coord.heading(.north) == Coord(2, 2))
        #expect(coord.heading(.south) == Coord(2, 4))
        #expect(coord.heading(.east) == Coord(3, 3))
        #expect(coord.heading(.west) == Coord(1, 3))
    }

    @Test("Guard.patrol should move on given map turning right when facing an obstacle until he exited the map and adding all seen position into its patrolReport")
    func guardPatrolTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        var labGuard = Guard(position: Coord(1, 3), heading: .north)
        try labGuard.patrol(on: labMap)
        expectNoDifference(labGuard.patrolReport, Set([
            Move(position: Coord(1, 3), heading: .north),
            Move(position: Coord(1, 2), heading: .north),
            Move(position: Coord(1, 1), heading: .north),
            Move(position: Coord(2, 1), heading: .east),
            Move(position: Coord(2, 2), heading: .south),
            Move(position: Coord(1, 2), heading: .west),
            Move(position: Coord(0, 2), heading: .west),
        ]))
    }

    @Test("Guard.patrol should throws an infiniteLoopPatrol when stuck in an infinite loop patrol")
    func guardPatrolInfiniteLoopTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
            Coord(0, 2),
        ]))
        var labGuard = Guard(position: Coord(1, 3), heading: .north)
        #expect {
            try labGuard.patrol(on: labMap)
        } throws: { error in
            (error as? Day6Error) == Day6Error.infiniteLoopPatrol
        }
        expectNoDifference(labGuard.patrolReport, Set([
            Move(position: Coord(1, 3), heading: .north),
            Move(position: Coord(1, 2), heading: .north),
            Move(position: Coord(1, 1), heading: .north),
            Move(position: Coord(2, 1), heading: .east),
            Move(position: Coord(2, 2), heading: .south),
            Move(position: Coord(1, 2), heading: .west),
        ]))
    }

    @Test("Coord.isInsideArea method should return true when coord is inside given area boundaries and false otherwise")
    func coordIsInsideAreaTest() throws {
        #expect(Coord(0, 0).isInsideArea(width: 4, height: 4) == true)
        #expect(Coord(3, 3).isInsideArea(width: 4, height: 4) == true)
        #expect(Coord(2, 2).isInsideArea(width: 4, height: 4) == true)
        #expect(Coord(4, 2).isInsideArea(width: 4, height: 4) == false)
        #expect(Coord(2, 4).isInsideArea(width: 4, height: 4) == false)
        #expect(Coord(-1, 2).isInsideArea(width: 4, height: 4) == false)
        #expect(Coord(2, -1).isInsideArea(width: 4, height: 4) == false)
    }

    @Test("A valid Lab should be init with a labMap and a labGuard that is inside the Map")
    func labCreationTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        #expect(Lab(labMap: labMap, labGuard: labGuard) != nil)
        #expect(Lab(labMap: labMap, labGuard: Guard(position: Coord(5, 5), heading: .north)) == nil)
    }

    @Test("A valid Lab should have a labMap property initialized with labMap argument")
    func labMapPropTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        let lab = try #require(Lab(labMap: labMap, labGuard: labGuard))
        expectNoDifference(lab.labMap, labMap)
    }

    @Test("A valid Lab should have a labGuard property initialized with labGuard argument")
    func labGuardPropTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        let lab = try #require(Lab(labMap: labMap, labGuard: labGuard))
        expectNoDifference(lab.labGuard, labGuard)
    }

    @Test("A valid Lab should have an observeGuardPatrol method that calls labGuard.patrol")
    func labObserveGuardPatrolTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        let lab = try #require(Lab(labMap: labMap, labGuard: labGuard))
        let initialPatrolReport = lab.patrolVisitReport
        try lab.observeGuardPatrol()
        #expect(lab.patrolVisitReport != initialPatrolReport)
    }

    @Test("A valid Lab should have a patrolVisitReport property equal to its labGuard patrolReport uniques positions")
    func labPatrolReportTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        let lab = try #require(Lab(labMap: labMap, labGuard: labGuard))
        expectNoDifference(lab.patrolVisitReport, [Coord(1, 3)])
        try lab.observeGuardPatrol()
        expectNoDifference(lab.patrolVisitReport, Set([
            Coord(1, 3),
            Coord(1, 2),
            Coord(1, 1),
            Coord(2, 1),
            Coord(2, 2),
            Coord(0, 2),
        ]))
    }

    @Test("Day6 reconLab method should parse input into a Lab class")
    func reconLabTest() throws {
        let input = """
        .#..
        ...#
        ....
        .^#.
        """
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        let reconLab = try Day6().reconLab(from: input)
        expectNoDifference(reconLab.labMap, labMap)
        expectNoDifference(reconLab.labGuard, labGuard)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day6().runPart1(with: inputPart)
        #expect(part1 == "41")
    }

    @Test("A valid Move should have position and heading properties set at init")
    func moveInitTest() {
        let position = Coord(1, 2)
        let heading = Direction.north
        let move = Move(position: position, heading: heading)
        expectNoDifference(move.position, position)
        expectNoDifference(move.heading, heading)
    }

    @Test("PatrolSimulator should have lab property set at init")
    func patrolSimulatorInitTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        let lab = try #require(Lab(labMap: labMap, labGuard: labGuard))

        let simulator = PatrolSimulator(lab: lab)

        expectNoDifference(simulator.lab.labMap, lab.labMap)
        expectNoDifference(simulator.lab.labGuard, lab.labGuard)
    }

    @Test("PatrolSimulator findAllInfinteLoopObstacles should return all obstacles on the original path of the guard that generates an infinite patrol")
    func findAllInfiniteLoopObstaclesTest() throws {
        let labMap = try #require(Map(width: 4, height: 4, obstacles: [
            Coord(1, 0),
            Coord(3, 1),
            Coord(2, 3),
        ]))
        let labGuard = Guard(position: Coord(1, 3), heading: .north)
        let lab = try #require(Lab(labMap: labMap, labGuard: labGuard))

        let patrolSimulator = PatrolSimulator(lab: lab)
        expectNoDifference(try patrolSimulator.findAllInfiniteLoopObstacles(), Set([
            Coord(0, 2),
        ]))
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day6().runPart2(with: inputPart)
        #expect(part2 == "6")
    }
}
