import Algorithms
import Core

public final class Day10: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        let topographicMap = try readMap(from: input)
        let allTrailheads = topographicMap.findTrailheads()
        return allTrailheads.map { trailhead in
            trailhead.evaluateTrail(on: topographicMap)
        }.sum().asText()
    }

    public func runPart2(with input: String) throws -> String {
        let topographicMap = try readMap(from: input)
        let allTrailheads = topographicMap.findTrailheads()
        return allTrailheads.map { trailhead in
            trailhead.evaluateTrailRating(on: topographicMap)
        }.sum().asText()
    }

    private func readMap(from input: String) throws -> TopographicMap {
        let lines = input.split(separator: "\n")
        let height = UInt(lines.count)
        var width = UInt(0)
        var points = [[TopographicPoint]]()
        for (y, line) in lines.enumerated() {
            width = UInt(line.count)
            var pointsLine = [TopographicPoint]()
            for (x, digit) in line.enumerated() {
                guard
                    let elevation = UInt("\(digit)"),
                    let point = TopographicPoint(position: Coord(x, y), elevation: elevation)
                else { throw Day10Error.invalidMapElevation }
                pointsLine.append(point)
            }
            points.append(pointsLine)
        }
        guard let topoMap = TopographicMap(width: width, height: height, points: points) else { throw Day10Error.inconsistentMapData }
        return topoMap
    }
}

enum Day10Error: Error {
    case inconsistentMapData
    case invalidMapElevation
}

struct TopographicMap: Equatable {
    let width: UInt
    let height: UInt
    private let points: [[TopographicPoint]]

    init?(width: UInt, height: UInt, points: [[TopographicPoint]]) {
        guard
            points.count == height &&
            points.enumerated().allSatisfy({ y, points in
                guard points.count == width else { return false }
                return points.enumerated().allSatisfy { x, point in
                    point.position == Coord(x, y)
                }
            })
        else { return nil }
        self.width = width
        self.height = height
        self.points = points
    }

    func findTrailheads() -> [Trailhead] {
        points.map {
            $0.filter { point in
                point.elevation == 0
            }
            .map { point in
                Trailhead(position: point.position)
            }
        }.flatMap { $0 }
    }

    func pointPositions(around position: Coord, atElevation elevation: UInt) -> [Coord] {
        let allAdjacentPositions = position.neighboursInsideArea(ofWidth: width, height: height)
        return allAdjacentPositions.filter { position in
            self.points[position.y][position.x].elevation == elevation
        }
    }
}

struct Trailhead: Equatable, Hashable {
    let position: Coord

    func evaluateTrail(on topoMap: TopographicMap) -> UInt {
        var validNextSteps = [position].uniqued()
        var nextElevation: UInt = 1
        while nextElevation < 10 {
            validNextSteps = validNextStepUniquePositions(validNextSteps, atElevation: nextElevation, on: topoMap)
            nextElevation += 1
        }
        return UInt(Array(validNextSteps).count)
    }

    private func validNextStepUniquePositions(_ positions: UniquedSequence<[Coord], Coord>, atElevation elevation: UInt, on topoMap: TopographicMap) -> UniquedSequence<[Coord], Coord> {
        positions.flatMap { topoMap.pointPositions(around: $0, atElevation: elevation) }.uniqued()
    }

    func evaluateTrailRating(on topoMap: TopographicMap) -> UInt {
        var validNextSteps = [position]
        var nextElevation: UInt = 1
        while nextElevation < 10 {
            validNextSteps = validNextStepPositions(validNextSteps, atElevation: nextElevation, on: topoMap)
            nextElevation += 1
        }
        return UInt(validNextSteps.count)
    }

    private func validNextStepPositions(_ positions: [Coord], atElevation elevation: UInt, on topoMap: TopographicMap) -> [Coord] {
        positions.flatMap { topoMap.pointPositions(around: $0, atElevation: elevation) }
    }
}

struct TopographicPoint: Equatable {
    let position: Coord
    let elevation: UInt

    init?(position: Coord, elevation: UInt) {
        guard elevation < 10 else { return nil }
        self.position = position
        self.elevation = elevation
    }
}
