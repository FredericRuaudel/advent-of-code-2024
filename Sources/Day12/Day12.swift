import Algorithms
import Core
import Foundation

public final class Day12: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        guard let garden = Garden(inventoryMap: input) else { throw Day12Error.invalidInput }
        let regions = garden.mapAllRegions()
        return regions.map(\.price).sum().asText()
    }

    public func runPart2(with input: String) throws -> String {
        guard let garden = Garden(inventoryMap: input) else { throw Day12Error.invalidInput }
        let regions = garden.mapAllRegions()
        return regions.map(\.discountedPrice).sum().asText()
    }
}

enum Day12Error: Error {
    case invalidInput
}

class Garden {
    var plantPlots: [[PlantPlot]]
    var width: UInt
    var height: UInt

    init?(inventoryMap: String) {
        plantPlots = []
        let lines = inventoryMap.split(separator: "\n")
        height = UInt(lines.count)
        width = UInt(lines.first?.count ?? 0)
        for (y, line) in lines.enumerated() {
            guard width == line.count else { return nil }
            var plantLine = [PlantPlot]()
            for (x, character) in line.enumerated() {
                guard character.unicodeScalars.allSatisfy({ CharacterSet.uppercaseLetters.contains($0) }) else { return nil }
                plantLine.append(PlantPlot(location: Coord(x, y), type: character))
            }
            plantPlots.append(plantLine)
        }
    }

    func plantPlot(at location: Coord) -> PlantPlot? {
        guard location.isInsideArea(width: width, height: height) else { return nil }
        return plantPlots[location.y][location.x]
    }

    func mapAllRegions() -> [Region] {
        var regions: [Region] = []
        var managedLocations: [Coord] = []
        for plantPlotLine in plantPlots {
            for plantPlot in plantPlotLine {
                if managedLocations.contains(plantPlot.location) { continue }
                let currentRegionLocations = findAllNeighbours(of: plantPlot).map(\.location)
                regions.append(Region(plotLocations: currentRegionLocations, plantType: plantPlot.type))
                managedLocations.append(contentsOf: currentRegionLocations)
            }
        }
        return regions
    }

    private func findAllNeighbours(
        of plantPlot: PlantPlot,
        currentNeighbourPlantPlots: [PlantPlot] = []
    ) -> [PlantPlot] {
        let newSameRegionNeighbours = plantPlot.location.neighboursInsideArea(ofWidth: width, height: height)
            .filter {
                guard let neighbourPlantPlot = self.plantPlot(at: $0.position) else { return false }
                return neighbourPlantPlot.type == plantPlot.type && currentNeighbourPlantPlots.contains(neighbourPlantPlot) == false
            }
        let updatedNeighbourPlantPlots = currentNeighbourPlantPlots + [plantPlot]

        guard newSameRegionNeighbours.isEmpty == false else { return updatedNeighbourPlantPlots }

        return newSameRegionNeighbours.reduce(into: updatedNeighbourPlantPlots) { updatedNeighbourPlantPlotsSoFar, neighbour in
            guard let neighbourPlantPlot = self.plantPlot(at: neighbour.position) else { return }
            updatedNeighbourPlantPlotsSoFar.append(
                contentsOf: findAllNeighbours(of: neighbourPlantPlot, currentNeighbourPlantPlots: updatedNeighbourPlantPlotsSoFar)
            )
            updatedNeighbourPlantPlotsSoFar = Array(updatedNeighbourPlantPlotsSoFar.uniqued())
        }
    }
}

struct Region: Equatable {
    let plotLocations: [Coord]
    let plantType: Character
    var perimeter: UInt {
        plotLocations.reduce(into: UInt(0)) { sum, location in
            sum += UInt(
                location.neighbours
                    .count { plotLocations.contains($0.position) == false }
            )
        }
    }

    var sides: UInt {
        let allNeighbours = plotLocations.flatMap(\.neighbours)
            .filter { plotLocations.contains($0.position) == false }

        struct Key: Hashable {
            let direction: Direction
            let axeValue: Int
        }

        let groupedNeighbours = Dictionary(grouping: allNeighbours) { neighbour in
            Key(direction: neighbour.direction, axeValue: neighbour.position.value(inAxe: neighbour.direction))
        }

        return groupedNeighbours.values.map { neighbours in
            neighbours.map { $0.position.value(orthogonalOfAxe: $0.direction) }
        }
        .reduce(into: 0) { count, values in
            count += values.consecutiveGroupCount()
        }
    }

    var area: UInt {
        UInt(plotLocations.count)
    }

    var price: UInt {
        area * perimeter
    }

    var discountedPrice: UInt {
        area * sides
    }
}

struct PlantPlot: Equatable, Hashable {
    let location: Coord
    let type: Character
}
