import Core
import CustomDump
@testable import Day14
import Parsing
import Testing

struct Day14Tests {
    let inputPart = """
    p=0,4 v=3,-3
    p=6,3 v=-1,-3
    p=10,3 v=-1,2
    p=2,0 v=2,-1
    p=0,0 v=1,3
    p=3,0 v=-2,-2
    p=7,6 v=-1,-3
    p=3,0 v=-1,-2
    p=9,3 v=2,3
    p=7,3 v=-1,2
    p=2,4 v=2,-3
    p=9,5 v=-3,-3
    """
    let exampleWidth: UInt = 11
    let exampleHeight: UInt = 7

    @Test("Robot should init with position and velocity, and return nil for negative position coordinates")
    func robotInitTest() throws {
        let validRobot = Robot(position: Coord(2, 3), velocity: Coord(-1, 2))
        #expect(validRobot != nil)

        let negativeXRobot = Robot(position: Coord(-1, 5), velocity: Coord(1, 1))
        #expect(negativeXRobot == nil)

        let negativeYRobot = Robot(position: Coord(5, -2), velocity: Coord(1, 1))
        #expect(negativeYRobot == nil)

        let negativeBothRobot = Robot(position: Coord(-3, -4), velocity: Coord(1, 1))
        #expect(negativeBothRobot == nil)
    }

    @Test("Robot should store position and velocity properties")
    func robotPropertiesTest() throws {
        let position1 = Coord(5, 7)
        let velocity1 = Coord(-2, 3)
        let robot1 = Robot(position: position1, velocity: velocity1)
        #expect(robot1?.position == position1)
        #expect(robot1?.velocity == velocity1)

        let position2 = Coord(10, 2)
        let velocity2 = Coord(1, -4)
        let robot2 = Robot(position: position2, velocity: velocity2)
        #expect(robot2?.position == position2)
        #expect(robot2?.velocity == velocity2)
    }

    @Test("Coord should support multiplication by Int")
    func coordMultiplicationTest() throws {
        let coord = Coord(3, 5)

        let result1 = coord * 2
        #expect(result1 == Coord(6, 10))

        let result2 = coord * -3
        #expect(result2 == Coord(-9, -15))

        let result3 = coord * 0
        #expect(result3 == Coord(0, 0))
    }

    @Test("Int should support multiplication with Coord")
    func intCoordMultiplicationTest() throws {
        let coord = Coord(3, 5)

        let result1 = 2 * coord
        #expect(result1 == Coord(6, 10))

        let result2 = -3 * coord
        #expect(result2 == Coord(-9, -15))

        let result3 = 0 * coord
        #expect(result3 == Coord(0, 0))
    }

    @Test("Robot should calculate position after duration within bounds")
    func robotPositionAfterDurationTest() throws {
        let robot = try #require(Robot(position: Coord(2, 4), velocity: Coord(2, -3)))

        let pos1 = robot.position(after: 1, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos1 == Coord(4, 1))

        let pos2 = robot.position(after: 2, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos2 == Coord(6, 5))

        let pos3 = robot.position(after: 3, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos3 == Coord(8, 2))

        let pos4 = robot.position(after: 4, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos4 == Coord(10, 6))

        let pos5 = robot.position(after: 5, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos5 == Coord(1, 3))

        // Test with different robot
        let robot2 = try #require(Robot(position: Coord(0, 0), velocity: Coord(2, 3)))

        let pos6 = robot2.position(after: 1, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos6 == Coord(2, 3))

        let pos7 = robot2.position(after: 2, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos7 == Coord(4, 6))

        // Testing edge cases
        let robot3 = try #require(Robot(position: Coord(7, 6), velocity: Coord(-1, -3)))

        let pos8 = robot3.position(after: 7, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos8 == Coord(0, 6))

        let pos9 = robot3.position(after: 100, insideAreaOfWidth: exampleWidth, height: exampleHeight)
        #expect(pos9 == Coord(6, 0))
    }

    @Test("Array of Coord should count robots by position")
    func robotCountByPositionTest() throws {
        let positions = [
            Coord(1, 2),
            Coord(3, 4),
            Coord(1, 2),
            Coord(5, 6),
            Coord(3, 4),
            Coord(1, 2),
        ]

        let countByPosition = positions.robotCountByPosition()

        #expect(countByPosition.count == 3)
        #expect(countByPosition[Coord(1, 2)] == 3)
        #expect(countByPosition[Coord(3, 4)] == 2)
        #expect(countByPosition[Coord(5, 6)] == 1)

        // Second example with different positions
        let positions2 = [
            Coord(0, 0),
            Coord(2, 3),
            Coord(0, 0),
            Coord(4, 5),
            Coord(2, 3),
            Coord(4, 5),
            Coord(4, 5),
        ]

        let countByPosition2 = positions2.robotCountByPosition()

        #expect(countByPosition2.count == 3)
        #expect(countByPosition2[Coord(0, 0)] == 2)
        #expect(countByPosition2[Coord(2, 3)] == 2)
        #expect(countByPosition2[Coord(4, 5)] == 3)
    }

    @Test("Dictionary of Coord to UInt should validate quadrant dimensions")
    func robotCountByQuadrantValidationTest() throws {
        let robotsByPosition: [Coord: UInt] = [
            Coord(0, 0): 1,
        ]

        // Even dimensions should return nil
        let evenWidth = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 4, height: 5)
        #expect(evenWidth == nil)

        let evenHeight = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 5, height: 6)
        #expect(evenHeight == nil)

        let evenBoth = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 4, height: 8)
        #expect(evenBoth == nil)

        // Odd dimensions should not return nil
        let oddDimensions = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 5, height: 5)
        #expect(oddDimensions != nil)

        let oddDimensions2 = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 3, height: 3)
        #expect(oddDimensions2 != nil)

        let oddDimensions3 = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 7, height: 7)
        #expect(oddDimensions3 != nil)
    }

    @Test("Coord should determine its quadrant relative to a center point")
    func coordQuadrantTest() throws {
        let center = Coord(2, 2)

        // Test top left quadrant
        #expect(Coord(0, 0).quadrant(withCenter: center) == .topLeft)
        #expect(Coord(1, 1).quadrant(withCenter: center) == .topLeft)
        #expect(Coord(2, 0).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(0, 2).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(2, 2).quadrant(withCenter: center) == nil) // Center

        // Test top right quadrant
        #expect(Coord(3, 0).quadrant(withCenter: center) == .topRight)
        #expect(Coord(4, 1).quadrant(withCenter: center) == .topRight)
        #expect(Coord(2, 0).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(3, 2).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(2, 2).quadrant(withCenter: center) == nil) // Center

        // Test bottom left quadrant
        #expect(Coord(0, 3).quadrant(withCenter: center) == .bottomLeft)
        #expect(Coord(1, 4).quadrant(withCenter: center) == .bottomLeft)
        #expect(Coord(2, 3).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(0, 2).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(2, 2).quadrant(withCenter: center) == nil) // Center

        // Test bottom right quadrant
        #expect(Coord(3, 3).quadrant(withCenter: center) == .bottomRight)
        #expect(Coord(4, 4).quadrant(withCenter: center) == .bottomRight)
        #expect(Coord(2, 3).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(3, 2).quadrant(withCenter: center) == nil) // Border
        #expect(Coord(2, 2).quadrant(withCenter: center) == nil) // Center

        // Test with different center point
        let center2 = Coord(3, 3)
        #expect(Coord(1, 1).quadrant(withCenter: center2) == .topLeft)
        #expect(Coord(5, 1).quadrant(withCenter: center2) == .topRight)
        #expect(Coord(1, 5).quadrant(withCenter: center2) == .bottomLeft)
        #expect(Coord(5, 5).quadrant(withCenter: center2) == .bottomRight)
        #expect(Coord(3, 3).quadrant(withCenter: center2) == nil) // Center
    }

    @Test("Dictionary of Coord to UInt should count robots by quadrant")
    func robotCountByQuadrantTest() throws {
        let robotsByPosition: [Coord: UInt] = [
            Coord(0, 0): 1,
            Coord(1, 1): 1,
            Coord(3, 0): 2,
            Coord(4, 1): 1,
            Coord(0, 3): 1,
            Coord(3, 3): 3,
            Coord(4, 4): 1,
            Coord(2, 0): 1,
            Coord(0, 2): 2,
            Coord(2, 2): 3,
            Coord(4, 2): 1,
            Coord(2, 4): 2,
        ]

        let countByQuadrant = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 5, height: 5)
        #expect(countByQuadrant != nil)
        #expect(countByQuadrant?[.topLeft] == 2)
        #expect(countByQuadrant?[.topRight] == 3)
        #expect(countByQuadrant?[.bottomLeft] == 1)
        #expect(countByQuadrant?[.bottomRight] == 4)

        // Test with different odd dimensions
        let countByQuadrant2 = robotsByPosition.robotCountByQuadrant(insideAreaOfWidth: 7, height: 7)
        #expect(countByQuadrant2 != nil)
        #expect(countByQuadrant2?[.topLeft] == 8)
        #expect(countByQuadrant2?[.topRight] == 2)
        #expect(countByQuadrant2?[.bottomLeft] == 2)
        #expect(countByQuadrant2?[.bottomRight] == 1)
    }

    @Test("CoordParser should parse x,y into Coord model")
    func coordParserTest() throws {
        #expect(try CoordParser().parse("0,0") == Coord(0, 0))
        #expect(try CoordParser().parse("1,2") == Coord(1, 2))
        #expect(try CoordParser().parse("-3,4") == Coord(-3, 4))
        #expect(try CoordParser().parse("10,-5") == Coord(10, -5))
        #expect(try CoordParser().parse("123,456") == Coord(123, 456))
    }

    @Test("RobotParser should parse p=x,y v=x,y into Robot model")
    func robotParserTest() throws {
        #expect(try RobotParser().parse("p=0,0 v=1,1") == Robot(position: Coord(0, 0), velocity: Coord(1, 1)))
        #expect(try RobotParser().parse("p=5,3 v=-2,4") == Robot(position: Coord(5, 3), velocity: Coord(-2, 4)))
        #expect(try RobotParser().parse("p=10,7 v=0,-3") == Robot(position: Coord(10, 7), velocity: Coord(0, -3)))
        #expect(try RobotParser().parse("p=2,8 v=-1,-1") == Robot(position: Coord(2, 8), velocity: Coord(-1, -1)))
        #expect(try RobotParser().parse("p=-1,3 v=1,1") == nil)
    }

    @Test("AllRobotParser should parse list of robots from input")
    func allRobotParserTest() throws {
        let expectedRobots = [
            Robot(position: Coord(0, 4), velocity: Coord(3, -3)),
            Robot(position: Coord(6, 3), velocity: Coord(-1, -3)),
            Robot(position: Coord(10, 3), velocity: Coord(-1, 2)),
            Robot(position: Coord(2, 0), velocity: Coord(2, -1)),
            Robot(position: Coord(0, 0), velocity: Coord(1, 3)),
            Robot(position: Coord(3, 0), velocity: Coord(-2, -2)),
            Robot(position: Coord(7, 6), velocity: Coord(-1, -3)),
            Robot(position: Coord(3, 0), velocity: Coord(-1, -2)),
            Robot(position: Coord(9, 3), velocity: Coord(2, 3)),
            Robot(position: Coord(7, 3), velocity: Coord(-1, 2)),
            Robot(position: Coord(2, 4), velocity: Coord(2, -3)),
            Robot(position: Coord(9, 5), velocity: Coord(-3, -3)),
        ]

        let parsedRobots = try AllRobotParser().parse(inputPart)

        #expect(parsedRobots == expectedRobots)
    }

    @Test("Part1 challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day14(
            bathroomWidth: exampleWidth,
            bathroomHeight: exampleHeight
        ).runPart1(with: inputPart)
        #expect(part1 == "12")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day14().runPart2(with: inputPart)
        #expect(part2 == "")
    }
}
