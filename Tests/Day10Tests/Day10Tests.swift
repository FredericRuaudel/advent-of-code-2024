import Core
import CustomDump
@testable import Day10
import Testing

struct Day10Tests {
    let inputPart = """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """

    @Test("Direction should have an offset property that returns a Coord representing the x,y offset for that direction")
    func directionOffsetTest() {
        #expect(Direction.north.offset == Coord(0, -1))
        #expect(Direction.east.offset == Coord(1, 0))
        #expect(Direction.south.offset == Coord(0, 1))
        #expect(Direction.west.offset == Coord(-1, 0))
    }

    @Test("TopographicPoint should be initialized with a position and an elevation less than 10 using a failable init")
    func topographicPointInitTest() {
        let validPoint = TopographicPoint(position: Coord(1, 2), elevation: 5)
        #expect(validPoint?.position == Coord(1, 2))
        #expect(validPoint?.elevation == 5)

        let validPoint2 = TopographicPoint(position: Coord(-2, 0), elevation: 0)
        #expect(validPoint2?.position == Coord(-2, 0))
        #expect(validPoint2?.elevation == 0)

        let validPoint3 = TopographicPoint(position: Coord(3, 3), elevation: 9)
        #expect(validPoint3?.position == Coord(3, 3))
        #expect(validPoint3?.elevation == 9)

        let invalidPoint = TopographicPoint(position: Coord(3, 4), elevation: 10)
        #expect(invalidPoint == nil)

        let invalidPoint2 = TopographicPoint(position: Coord(5, 5), elevation: 15)
        #expect(invalidPoint2 == nil)
    }

    @Test("Trailhead should have a position property of type Coord initialized with position argument")
    func trailheadPositionPropTest() {
        let trailhead = Trailhead(position: Coord(1, 2))
        #expect(trailhead.position == Coord(1, 2))

        let trailhead2 = Trailhead(position: Coord(0, 0))
        #expect(trailhead2.position == Coord(0, 0))

        let trailhead3 = Trailhead(position: Coord(-1, 3))
        #expect(trailhead3.position == Coord(-1, 3))
    }

    @Test("TopographicMap should be initialized with width, height and points array that matches dimensions and positions match array indexes")
    func topographicMapInitTest() throws {
        let points = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 1)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 2)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 3)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 4)),
            ],
        ]

        let validMap = TopographicMap(width: 2, height: 2, points: points)
        #expect(validMap != nil)

        let invalidWidthPoints = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 1)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 2)),
            ],
        ]
        let invalidWidthMap = TopographicMap(width: 2, height: 2, points: invalidWidthPoints)
        #expect(invalidWidthMap == nil)

        let invalidHeightPoints = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 1)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 2)),
            ],
        ]
        let invalidHeightMap = TopographicMap(width: 2, height: 2, points: invalidHeightPoints)
        #expect(invalidHeightMap == nil)

        let emptyPoints: [[TopographicPoint]] = []
        let emptyMap = TopographicMap(width: 2, height: 2, points: emptyPoints)
        #expect(emptyMap == nil)

        // Test invalid positions
        let invalidPositionPoints = try [
            [
                #require(TopographicPoint(position: Coord(1, 0), elevation: 1)), // x should be 0
                #require(TopographicPoint(position: Coord(0, 0), elevation: 2)), // x should be 1
            ],
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 3)), // y should be 1
                #require(TopographicPoint(position: Coord(1, 0), elevation: 4)), // y should be 1
            ],
        ]
        let invalidPositionMap = TopographicMap(width: 2, height: 2, points: invalidPositionPoints)
        #expect(invalidPositionMap == nil)
    }

    @Test("TopographicMap should expose width and height properties")
    func topographicMapPropertiesTest() throws {
        let points = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 1)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 2)),
                #require(TopographicPoint(position: Coord(2, 0), elevation: 3)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 4)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 5)),
                #require(TopographicPoint(position: Coord(2, 1), elevation: 6)),
            ],
        ]

        let map = try #require(TopographicMap(width: 3, height: 2, points: points))
        #expect(map.width == 3)
        #expect(map.height == 2)
    }

    @Test("TopographicMap should find trailheads at elevation 0")
    func findTrailheadsTest() throws {
        let points = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 0)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 2)),
                #require(TopographicPoint(position: Coord(2, 0), elevation: 0)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 4)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 0)),
                #require(TopographicPoint(position: Coord(2, 1), elevation: 6)),
            ],
        ]

        let map = try #require(TopographicMap(width: 3, height: 2, points: points))
        let trailheads = map.findTrailheads()

        let expectedTrailheads = [
            Trailhead(position: Coord(0, 0)),
            Trailhead(position: Coord(2, 0)),
            Trailhead(position: Coord(1, 1)),
        ]

        #expect(trailheads.count == 3)
        #expect(Set(trailheads) == Set(expectedTrailheads))
    }

    @Test("TopographicMap should find directly adjacent points at given elevation")
    func findAdjacentPointsTest() throws {
        let points = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 1)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 2)),
                #require(TopographicPoint(position: Coord(2, 0), elevation: 2)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 2)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 3)),
                #require(TopographicPoint(position: Coord(2, 1), elevation: 4)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 2), elevation: 4)),
                #require(TopographicPoint(position: Coord(1, 2), elevation: 2)),
                #require(TopographicPoint(position: Coord(2, 2), elevation: 6)),
            ],
        ]

        let map = try #require(TopographicMap(width: 3, height: 3, points: points))

        // First example - checking points adjacent to (1,1) at elevation 2
        let adjacentPoints = map.pointPositions(around: Coord(1, 1), atElevation: 2)
        let expectedPoints = [
            Coord(1, 0), // up
            Coord(0, 1), // left
            Coord(1, 2), // down
        ]
        #expect(adjacentPoints.count == 3)
        #expect(Set(adjacentPoints) == Set(expectedPoints))

        // Second example - checking points adjacent to (2,0) at elevation 4
        let moreAdjacentPoints = map.pointPositions(around: Coord(1, 1), atElevation: 4)
        let moreExpectedPoints = [
            Coord(2, 1), // down
        ]
        #expect(moreAdjacentPoints.count == 1)
        #expect(Set(moreAdjacentPoints) == Set(moreExpectedPoints))
    }

    @Test("Trailhead should evaluate all possible paths from elevation 0 to 9 on map, counting the unique number of summit that can be reached")
    func trailheadEvaluateTrailTest() throws {
        let points = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(2, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(3, 0), elevation: 0)),
                #require(TopographicPoint(position: Coord(4, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(5, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(6, 0), elevation: 9)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(2, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(3, 1), elevation: 1)),
                #require(TopographicPoint(position: Coord(4, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(5, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(6, 1), elevation: 7)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(1, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(2, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(3, 2), elevation: 2)),
                #require(TopographicPoint(position: Coord(4, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(5, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(6, 2), elevation: 8)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 3), elevation: 6)),
                #require(TopographicPoint(position: Coord(1, 3), elevation: 5)),
                #require(TopographicPoint(position: Coord(2, 3), elevation: 4)),
                #require(TopographicPoint(position: Coord(3, 3), elevation: 3)),
                #require(TopographicPoint(position: Coord(4, 3), elevation: 4)),
                #require(TopographicPoint(position: Coord(5, 3), elevation: 5)),
                #require(TopographicPoint(position: Coord(6, 3), elevation: 6)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 4), elevation: 7)),
                #require(TopographicPoint(position: Coord(1, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(2, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(3, 4), elevation: 4)),
                #require(TopographicPoint(position: Coord(4, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(5, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(6, 4), elevation: 7)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 5), elevation: 8)),
                #require(TopographicPoint(position: Coord(1, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(2, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(3, 5), elevation: 5)),
                #require(TopographicPoint(position: Coord(4, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(5, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(6, 5), elevation: 8)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 6), elevation: 9)),
                #require(TopographicPoint(position: Coord(1, 6), elevation: 2)),
                #require(TopographicPoint(position: Coord(2, 6), elevation: 2)),
                #require(TopographicPoint(position: Coord(3, 6), elevation: 6)),
                #require(TopographicPoint(position: Coord(4, 6), elevation: 7)),
                #require(TopographicPoint(position: Coord(5, 6), elevation: 8)),
                #require(TopographicPoint(position: Coord(6, 6), elevation: 9)),
            ],
        ]

        let map = try #require(TopographicMap(width: 7, height: 7, points: points))
        let trailhead = Trailhead(position: Coord(3, 0))

        #expect(trailhead.evaluateTrail(on: map) == 2)

        // Test with a map that has no valid paths
        let pointsWithNoPath = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 0)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 1)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 1)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 2)),
            ],
        ]

        let mapWithNoPath = try #require(TopographicMap(width: 2, height: 2, points: pointsWithNoPath))
        let trailheadWithNoPath = Trailhead(position: Coord(0, 0))
        
        #expect(trailheadWithNoPath.evaluateTrail(on: mapWithNoPath) == 0)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day10().runPart1(with: inputPart)
        #expect(part1 == "36")
    }

    @Test("Trailhead should evaluate all possible paths from elevation 0 to 9 on map counting each possible trail to reach each summit")
    func trailheadEvaluateTrailRatingTest() throws {
        let points = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(2, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(3, 0), elevation: 0)),
                #require(TopographicPoint(position: Coord(4, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(5, 0), elevation: 9)),
                #require(TopographicPoint(position: Coord(6, 0), elevation: 9)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(2, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(3, 1), elevation: 1)),
                #require(TopographicPoint(position: Coord(4, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(5, 1), elevation: 7)),
                #require(TopographicPoint(position: Coord(6, 1), elevation: 7)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(1, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(2, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(3, 2), elevation: 2)),
                #require(TopographicPoint(position: Coord(4, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(5, 2), elevation: 8)),
                #require(TopographicPoint(position: Coord(6, 2), elevation: 8)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 3), elevation: 6)),
                #require(TopographicPoint(position: Coord(1, 3), elevation: 5)),
                #require(TopographicPoint(position: Coord(2, 3), elevation: 4)),
                #require(TopographicPoint(position: Coord(3, 3), elevation: 3)),
                #require(TopographicPoint(position: Coord(4, 3), elevation: 4)),
                #require(TopographicPoint(position: Coord(5, 3), elevation: 5)),
                #require(TopographicPoint(position: Coord(6, 3), elevation: 6)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 4), elevation: 7)),
                #require(TopographicPoint(position: Coord(1, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(2, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(3, 4), elevation: 4)),
                #require(TopographicPoint(position: Coord(4, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(5, 4), elevation: 1)),
                #require(TopographicPoint(position: Coord(6, 4), elevation: 7)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 5), elevation: 8)),
                #require(TopographicPoint(position: Coord(1, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(2, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(3, 5), elevation: 5)),
                #require(TopographicPoint(position: Coord(4, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(5, 5), elevation: 3)),
                #require(TopographicPoint(position: Coord(6, 5), elevation: 8)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 6), elevation: 9)),
                #require(TopographicPoint(position: Coord(1, 6), elevation: 2)),
                #require(TopographicPoint(position: Coord(2, 6), elevation: 2)),
                #require(TopographicPoint(position: Coord(3, 6), elevation: 6)),
                #require(TopographicPoint(position: Coord(4, 6), elevation: 7)),
                #require(TopographicPoint(position: Coord(5, 6), elevation: 8)),
                #require(TopographicPoint(position: Coord(6, 6), elevation: 9)),
            ],
        ]

        let map = try #require(TopographicMap(width: 7, height: 7, points: points))
        let trailhead = Trailhead(position: Coord(3, 0))

        #expect(trailhead.evaluateTrailRating(on: map) == 3)

        // Test with a map that has no valid paths
        let pointsWithNoPath = try [
            [
                #require(TopographicPoint(position: Coord(0, 0), elevation: 0)),
                #require(TopographicPoint(position: Coord(1, 0), elevation: 1)),
            ],
            [
                #require(TopographicPoint(position: Coord(0, 1), elevation: 1)),
                #require(TopographicPoint(position: Coord(1, 1), elevation: 2)),
            ],
        ]

        let mapWithNoPath = try #require(TopographicMap(width: 2, height: 2, points: pointsWithNoPath))
        let trailheadWithNoPath = Trailhead(position: Coord(0, 0))
        
        #expect(trailheadWithNoPath.evaluateTrailRating(on: mapWithNoPath) == 0)
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day10().runPart2(with: inputPart)
        #expect(part2 == "81")
    }
}
