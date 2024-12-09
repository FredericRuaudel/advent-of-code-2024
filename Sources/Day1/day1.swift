import Core
import Parsing

public final class Day1: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        var (leftLocationIds, rightLocationIds) = try parse(input)
        leftLocationIds.sort()
        rightLocationIds.sort()

        let distances = zip(leftLocationIds, rightLocationIds).map { leftId, rightId in
            abs(leftId - rightId)
        }

        return "\(distances.reduce(0, +))"
    }

    public func runPart2(with input: String) throws -> String {
        let (leftLocationIds, rightLocationIds) = try parse(input)

        let similarityScores = leftLocationIds.map { leftId in
            leftId * rightLocationIds.filter { $0 == leftId }.count
        }

        return "\(similarityScores.reduce(0, +))"
    }

    private func parse(_ input: String) throws -> ([Int], [Int]) {
        let values = try MainParser().parse(input)

        return values.reduce(([Int](), [Int]())) { partialResult, tuple in
            var nextResult = partialResult
            nextResult.0.append(tuple.0)
            nextResult.1.append(tuple.1)
            return nextResult
        }
    }
}

struct LocationIdTupleParser: Parser {
    var body: some Parser<Substring, (Int, Int)> {
        Int.parser()
        Whitespace(.horizontal)
        Int.parser()
    }
}

struct MainParser: Parser {
    var body: some Parser<Substring, [(Int, Int)]> {
        Many {
            LocationIdTupleParser()
        } separator: {
            Whitespace(.vertical)
        }
    }
}
