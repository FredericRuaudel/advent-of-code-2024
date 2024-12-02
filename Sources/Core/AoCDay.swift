import Foundation

public protocol AoCDay {
    init()
    func runPart1(with input: String) throws -> String
    func runPart2(with input: String) throws -> String
}
