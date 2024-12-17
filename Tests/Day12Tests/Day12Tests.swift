import Core
import CustomDump
@testable import Day12
import Testing

struct Day12Tests {
    let inputPart = """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """

    @Test("PlantPlot has location and type properties")
    func plantPlotProperties() {
        let location = Coord(1, 2)
        let type: Character = "R"

        let plot = PlantPlot(location: location, type: type)

        #expect(plot.location == location)
        #expect(plot.type == type)
    }

    @Test("Region has plotLocations and plantType properties")
    func regionProperties() {
        let locations = [
            Coord(0, 0),
            Coord(0, 1),
            Coord(1, 0),
        ]
        let type: Character = "R"

        let region = Region(plotLocations: locations, plantType: type)

        expectNoDifference(region.plotLocations, locations)
        #expect(region.plantType == type)
    }

    @Test("Region has area property equal to number of plotLocations")
    func regionArea() {
        let locations1 = [
            Coord(0, 0),
            Coord(0, 1),
            Coord(1, 0),
            Coord(1, 1),
        ]
        let type1: Character = "R"

        let region1 = Region(plotLocations: locations1, plantType: type1)
        #expect(region1.area == 4)

        let locations2 = [
            Coord(0, 0),
            Coord(0, 1),
            Coord(0, 2),
            Coord(1, 1),
            Coord(2, 0),
            Coord(2, 1),
            Coord(2, 2),
        ]
        let type2: Character = "C"

        let region2 = Region(plotLocations: locations2, plantType: type2)
        #expect(region2.area == 7)
    }

    @Test("Region has perimeter property equal to number of non-region adjacent sides")
    func regionPerimeter() {
        let locations1 = [
            Coord(0, 0),
            Coord(0, 1),
            Coord(1, 0),
            Coord(1, 1),
        ]
        let type1: Character = "C"

        let region1 = Region(plotLocations: locations1, plantType: type1)
        #expect(region1.perimeter == 8) // Each corner plot has 2 external sides = 8 total

        let locations2 = [
            Coord(0, 0),
            Coord(0, 1),
            Coord(0, 2),
            Coord(1, 1),
            Coord(2, 0),
            Coord(2, 1),
            Coord(2, 2),
        ]
        let type2: Character = "H"

        let region2 = Region(plotLocations: locations2, plantType: type2)
        #expect(region2.perimeter == 16) // Outer plots have varying external sides totaling 12
    }

    @Test("Region has price property equal to area times perimeter")
    func regionPrice() {
        let locations1 = [
            Coord(0, 0),
            Coord(0, 1),
            Coord(1, 0),
            Coord(1, 1),
        ]
        let type1: Character = "C"

        let region1 = Region(plotLocations: locations1, plantType: type1)
        #expect(region1.price == 32) // 4 (area) * 8 (perimeter) = 32

        let locations2 = [
            Coord(0, 0),
            Coord(0, 1),
            Coord(0, 2),
            Coord(1, 1),
            Coord(2, 0),
            Coord(2, 1),
            Coord(2, 2),
        ]
        let type2: Character = "H"

        let region2 = Region(plotLocations: locations2, plantType: type2)
        #expect(region2.price == 112) // 7 (area) * 16 (perimeter) = 112
    }

    @Test("Garden init should return nil when inventoryMap contains non-capital letters or non-alpha characters")
    func gardenInitInvalidInput() {
        let invalidInput1 = """
        ABc
        DEF
        """
        #expect(Garden(inventoryMap: invalidInput1) == nil)

        let invalidInput2 = """
        123
        ABC
        """
        #expect(Garden(inventoryMap: invalidInput2) == nil)

        let invalidInput3 = """
        AB.
        DEF
        """
        #expect(Garden(inventoryMap: invalidInput3) == nil)

        let invalidInput4 = """
        ABC
        D#F
        """
        #expect(Garden(inventoryMap: invalidInput4) == nil)

        let invalidInput5 = """
        AB@
        DEF
        """
        #expect(Garden(inventoryMap: invalidInput5) == nil)
    }

    @Test("Garden init should return nil when inventoryMap has lines with different lengths")
    func gardenInitDifferentLineLengths() {
        let invalidInput1 = """
        ABC
        DEFG
        """
        #expect(Garden(inventoryMap: invalidInput1) == nil)

        let invalidInput2 = """
        ABCD
        EF
        GHI
        """
        #expect(Garden(inventoryMap: invalidInput2) == nil)

        let invalidInput3 = """
        A
        BC
        DEF
        """
        #expect(Garden(inventoryMap: invalidInput3) == nil)
    }

    @Test("Garden is initialized with plantPlots array parsed from input string containing only capital letters")
    func gardenInit() throws {
        let inputPart = """
        ACD
        BCA
        """
        let garden = try #require(Garden(inventoryMap: inputPart))

        let expectedPlots = [
            [
                PlantPlot(location: Coord(0, 0), type: "A"),
                PlantPlot(location: Coord(1, 0), type: "C"),
                PlantPlot(location: Coord(2, 0), type: "D"),
            ],
            [
                PlantPlot(location: Coord(0, 1), type: "B"),
                PlantPlot(location: Coord(1, 1), type: "C"),
                PlantPlot(location: Coord(2, 1), type: "A"),
            ],
        ]

        #expect(garden.plantPlots.count == 2)
        #expect(garden.plantPlots[0].count == 3)
        #expect(garden.plantPlots[1].count == 3)
        #expect(garden.plantPlots == expectedPlots)
        expectNoDifference(garden.plantPlots, expectedPlots)
    }

    @Test("Garden is initialized with width and height properties corresponding to input dimensions")
    func gardenDimensions() throws {
        let inputPart = """
        ACD
        BCA
        DEF
        """
        let garden = try #require(Garden(inventoryMap: inputPart))

        #expect(garden.width == 3)
        #expect(garden.height == 3)

        let inputPart2 = """
        ABCD
        EFGH
        """
        let garden2 = try #require(Garden(inventoryMap: inputPart2))

        #expect(garden2.width == 4)
        #expect(garden2.height == 2)
    }

    @Test("Coord has neighbours method that returns adjacent coordinates")
    func coordNeighboursMethod() {
        let coord = Coord(1, 1)
        let expectedNeighbours = [
            Coord(1, 0), // north
            Coord(2, 1), // east
            Coord(1, 2), // south
            Coord(0, 1), // west
        ]

        expectNoDifference(coord.neighbours, expectedNeighbours)

        let coord2 = Coord(0, 0)
        let expectedNeighbours2 = [
            Coord(0, -1), // north
            Coord(1, 0), // east
            Coord(0, 1), // south
            Coord(-1, 0), // west
        ]

        expectNoDifference(coord2.neighbours, expectedNeighbours2)
    }

    @Test("Coord has neighboursInsideArea method that returns all adjacent coordinates inside given area")
    func coordNeighbours() {
        let coord = Coord(1, 1)
        let neighbours = [
            Coord(1, 0), // north
            Coord(2, 1), // east
            Coord(1, 2), // south
            Coord(0, 1), // west
        ]

        expectNoDifference(coord.neighboursInsideArea(ofWidth: 3, height: 3), neighbours)

        // Test edge case
        let edgeCoord = Coord(0, 0)
        let edgeNeighbours = [
            Coord(1, 0), // east
            Coord(0, 1), // south
        ]

        expectNoDifference(edgeCoord.neighboursInsideArea(ofWidth: 2, height: 2), edgeNeighbours)

        // Test another edge case
        let cornerCoord = Coord(0, 1)
        let cornerNeighbours = [
            Coord(0, 0), // north
            Coord(1, 1), // east
            Coord(0, 2), // south
        ]

        expectNoDifference(cornerCoord.neighboursInsideArea(ofWidth: 2, height: 3), cornerNeighbours)

        // Test filtering coordinates outside area
        let nearEdgeCoord = Coord(1, 1)
        let filteredNeighbours = [
            Coord(1, 0), // north
            Coord(0, 1), // west
        ]

        expectNoDifference(nearEdgeCoord.neighboursInsideArea(ofWidth: 2, height: 2), filteredNeighbours)
    }

    @Test("Garden has method to find plant plot at given location")
    func gardenFindPlantPlot() throws {
        let input = """
        ABC
        DEF
        """
        let garden = try #require(Garden(inventoryMap: input))

        // Test finding existing plots
        let topLeft = garden.plantPlot(at: Coord(0, 0))
        #expect(topLeft?.type == "A")

        let middle = garden.plantPlot(at: Coord(1, 1))
        #expect(middle?.type == "E")

        let bottomRight = garden.plantPlot(at: Coord(2, 1))
        #expect(bottomRight?.type == "F")

        // Test coordinates outside garden return nil
        #expect(garden.plantPlot(at: Coord(-1, 0)) == nil)
        #expect(garden.plantPlot(at: Coord(0, -1)) == nil)
        #expect(garden.plantPlot(at: Coord(3, 0)) == nil)
        #expect(garden.plantPlot(at: Coord(0, 2)) == nil)
    }

    @Test("Garden can map all regions from plant plots")
    func gardenMapRegions() throws {
        let input = """
        AAD
        CAD
        BBA
        """
        let garden = try #require(Garden(inventoryMap: input))

        let regions = garden.mapAllRegions()
        #expect(regions.count == 5)

        let regionsA = regions.filter { $0.plantType == "A" }
        #expect(regionsA.count == 2)

        // First A region (top left, 3 plots)
        let topRegionA = regionsA.first { region in
            region.plotLocations.contains(Coord(0, 0))
        }
        #expect(topRegionA?.area == 3)
        #expect(topRegionA?.perimeter == 8)

        // Second A region (bottom right, 1 plot)
        let bottomRegionA = regionsA.first { region in
            region.plotLocations.contains(Coord(2, 2))
        }
        #expect(bottomRegionA?.area == 1)
        #expect(bottomRegionA?.perimeter == 4)

        let regionB = regions.first { $0.plantType == "B" }
        #expect(regionB?.area == 2)
        #expect(regionB?.perimeter == 6)

        let regionC = regions.first { $0.plantType == "C" }
        #expect(regionC?.area == 1)
        #expect(regionC?.perimeter == 4)

        let regionD = regions.first { $0.plantType == "D" }
        #expect(regionD?.area == 2)
        #expect(regionD?.perimeter == 6)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day12().runPart1(with: inputPart)
        #expect(part1 == "1930")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day12().runPart2(with: inputPart)
        #expect(part2 == "")
    }
}
