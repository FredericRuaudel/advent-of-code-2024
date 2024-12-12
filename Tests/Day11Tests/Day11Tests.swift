import CustomDump
@testable import Day11
import Testing

struct Day11Tests {
    let inputPart = "125 17"

    @Test("A Stone should have a number property set via init")
    func stoneNumberPropertyTest() {
        let stone1 = Stone(number: 1)
        #expect(stone1.number == 1)

        let stone2 = Stone(number: 42)
        #expect(stone2.number == 42)

        let stone3 = Stone(number: 0)
        #expect(stone3.number == 0)
    }

    @Test("Stone should have a failable init with string that returns nil if string is not a number")
    func stoneStringInitTest() {
        let validStone = Stone(splittedNumber: "42"[...])
        #expect(validStone?.number == 42)

        let validStone2 = Stone(splittedNumber: "0"[...])
        #expect(validStone2?.number == 0)

        let validStone3 = Stone(splittedNumber: "123"[...])
        #expect(validStone3?.number == 123)

        let invalidStone = Stone(splittedNumber: "abc"[...])
        #expect(invalidStone == nil)

        let invalidStone2 = Stone(splittedNumber: "12.34"[...])
        #expect(invalidStone2 == nil)

        let invalidStone3 = Stone(splittedNumber: "-5"[...])
        #expect(invalidStone3 == nil)
    }

    @Test("Stone init with splittedNumber should handle strings with leading zeros")
    func stoneStringInitWithLeadingZerosTest() {
        let stoneWithOneZero = Stone(splittedNumber: "042"[...])
        #expect(stoneWithOneZero?.number == 42)

        let stoneWithMultipleZeros = Stone(splittedNumber: "00123"[...])
        #expect(stoneWithMultipleZeros?.number == 123)

        let stoneAllZeros = Stone(splittedNumber: "000"[...])
        #expect(stoneAllZeros?.number == 0)

        let stoneSingleZero = Stone(splittedNumber: "0"[...])
        #expect(stoneSingleZero?.number == 0)
    }

    @Test("Stone should have an isZero property that returns true if number is 0")
    func stoneIsZeroPropertyTest() {
        let zeroStone = Stone(number: 0)
        #expect(zeroStone.isZero == true)

        let nonZeroStone = Stone(number: 42)
        #expect(nonZeroStone.isZero == false)

        let anotherNonZeroStone = Stone(number: 1)
        #expect(anotherNonZeroStone.isZero == false)
    }

    @Test("Stone should have a hasEvenDigitCount function that returns true if number has even number of digits")
    func stoneHasEvenDigitCountTest() {
        let singleDigitStone = Stone(number: 5)
        #expect(singleDigitStone.hasEvenDigitCount() == false)

        let twoDigitStone = Stone(number: 42)
        #expect(twoDigitStone.hasEvenDigitCount() == true)

        let threeDigitStone = Stone(number: 123)
        #expect(threeDigitStone.hasEvenDigitCount() == false)

        let fourDigitStone = Stone(number: 1234)
        #expect(fourDigitStone.hasEvenDigitCount() == true)

        let zeroStone = Stone(number: 0)
        #expect(zeroStone.hasEvenDigitCount() == false)
    }

    @Test("StoneEvolution should be an enum with .updated case and stones property")
    func stoneEvolutionTest() {
        let stone = Stone(number: 42)
        let evolution = StoneEvolution.updated(stone)

        #expect(evolution.stones == [stone])

        let anotherStone = Stone(number: 123)
        let anotherEvolution = StoneEvolution.updated(anotherStone)

        #expect(anotherEvolution.stones == [anotherStone])
    }

    @Test("StoneEvolution should have a .splitted case and stones property should return array of both stones")
    func stoneEvolutionSplittedTest() {
        let stone1 = Stone(number: 42)
        let stone2 = Stone(number: 123)
        let evolution = StoneEvolution.splitted(stone1, stone2)

        #expect(evolution.stones == [stone1, stone2])

        let anotherStone1 = Stone(number: 0)
        let anotherStone2 = Stone(number: 1)
        let anotherEvolution = StoneEvolution.splitted(anotherStone1, anotherStone2)

        #expect(anotherEvolution.stones == [anotherStone1, anotherStone2])
    }

    @Test("Stone should evolve to Stone(1) when number is 0")
    func stoneEvolveZeroTest() {
        let zeroStone = Stone(number: 0)
        let evolution = zeroStone.evolve()

        #expect(evolution == .updated(Stone(number: 1)))
    }

    @Test("Stone should split into two stones with half digits when number has even digit count")
    func stoneEvolveEvenDigitsTest() {
        let twoDigitStone = Stone(number: 42)
        let evolution = twoDigitStone.evolve()
        #expect(evolution == .splitted(Stone(number: 4), Stone(number: 2)))

        let fourDigitStone = Stone(number: 1234)
        let anotherEvolution = fourDigitStone.evolve()
        #expect(anotherEvolution == .splitted(Stone(number: 12), Stone(number: 34)))

        let fourDigitWithZeroStone = Stone(number: 1000)
        let zeroEvolution = fourDigitWithZeroStone.evolve()
        #expect(zeroEvolution == .splitted(Stone(number: 10), Stone(number: 0)))
    }

    @Test("Stone should evolve to Stone(number * 2024) when number is not zero and has odd digit count")
    func stoneEvolveOddDigitsTest() {
        let oneDigitStone = Stone(number: 5)
        let evolution = oneDigitStone.evolve()
        #expect(evolution == .updated(Stone(number: 5 * 2024)))

        let threeDigitStone = Stone(number: 123)
        let anotherEvolution = threeDigitStone.evolve()
        #expect(anotherEvolution == .updated(Stone(number: 123 * 2024)))

        let fiveDigitStone = Stone(number: 12345)
        let yetAnotherEvolution = fiveDigitStone.evolve()
        #expect(yetAnotherEvolution == .updated(Stone(number: 12345 * 2024)))
    }

    @Test("Observer init should return nil if environment is not a list of space-separated numbers")
    func observerInitInvalidInputTest() {
        let invalidInput = "42 abc 0 1000"
        let observer = Observer(environment: invalidInput)
        #expect(observer == nil)

        let anotherInvalidInput = "42,123,0,1000"
        let anotherObserver = Observer(environment: anotherInvalidInput)
        #expect(anotherObserver == nil)

        let emptyInput = ""
        let emptyObserver = Observer(environment: emptyInput)
        #expect(emptyObserver == nil)
    }

    @Test("Observer should initialize stones from space-separated numbers")
    func observerInitTest() {
        let input = "42 123 0 1000"
        let observer = Observer(environment: input)
        #expect(observer != nil)

        #expect(observer?.stones == [
            Stone(number: 42),
            Stone(number: 123),
            Stone(number: 0),
            Stone(number: 1000),
        ])

        let anotherInput = "1 2 3 4 5"
        let anotherObserver = Observer(environment: anotherInput)
        #expect(anotherObserver != nil)

        #expect(anotherObserver?.stones == [
            Stone(number: 1),
            Stone(number: 2),
            Stone(number: 3),
            Stone(number: 4),
            Stone(number: 5),
        ])
    }

    @Test("Observer should have a visibleStones property that returns the count of stones")
    func observerStoneCountTest() {
        let input = "42 123 0 1000"
        let observer = Observer(environment: input)
        #expect(observer?.visibleStones == 4)

        let anotherInput = "1 2 3 4 5"
        let anotherObserver = Observer(environment: anotherInput)
        #expect(anotherObserver?.visibleStones == 5)

        let singleStoneInput = "42"
        let singleStoneObserver = Observer(environment: singleStoneInput)
        #expect(singleStoneObserver?.visibleStones == 1)
    }

    @Test("Observer should have a blink method that evolves stones the specified number of times")
    func observerBlinkTest() {
        let input = "0 2 42"
        let observer = Observer(environment: input)

        // After 1 blink:
        // 0 becomes 1
        // 2 becomes 4048 (2 * 2024)
        // 42 becomes 4 and 2 (split)
        observer?.blink(count: 1)
        #expect(observer?.stones == [
            Stone(number: 1),
            Stone(number: 4048),
            Stone(number: 4),
            Stone(number: 2),
        ])

        // After another blink:
        // 1 becomes 2024
        // 4048 splits into 40 and 48
        // 4 becomes 8096
        // 2 becomes 4048
        observer?.blink(count: 1)
        #expect(observer?.stones == [
            Stone(number: 2024),
            Stone(number: 40),
            Stone(number: 48),
            Stone(number: 8096),
            Stone(number: 4048),
        ])

        // Test multiple blinks at once
        let anotherInput = "0"
        let anotherObserver = Observer(environment: anotherInput)
        anotherObserver?.blink(count: 3)
        // 0 -> 1 -> 2024 -> 20 24
        #expect(anotherObserver?.stones == [
            Stone(number: 20),
            Stone(number: 24),
        ])
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day11().runPart1(with: inputPart)
        #expect(part1 == "55312")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day11().runPart2(with: inputPart)
        #expect(part2 == "")
    }
}
