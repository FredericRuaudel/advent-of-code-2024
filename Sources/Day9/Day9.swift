import CasePaths
import Core

public struct Day9: AoCDay {
    public init() {}

    public func runPart1(with input: String) throws -> String {
        let fragmentedDisk = try readFragmentedDisk(from: input)
        let cleanedDisk = fragmentedDisk.defrag()
        return cleanedDisk.checksum().asText()
    }

    public func runPart2(with _: String) throws -> String {
        ""
    }

    func readFragmentedDisk(from input: String) throws -> FragmentedDisk {
        var resultDisc = FragmentedDisk()
        for (i, digit) in input.enumerated() {
            guard let size = UInt("\(digit)") else { throw Day9Error.invalidSector }
            if i.isMultiple(of: 2) {
                try resultDisc.writeFile(ofSize: size)
            } else {
                try resultDisc.moveFilePointer(by: size)
            }
        }
        return resultDisc
    }
}

enum Day9Error: Error, Equatable {
    case fileEmpty
    case fileSizeTooLarge
    case invalidSector
    case writeOffsetTooLarge
}

struct FragmentedDisk: Equatable {
    private(set) var content: [DiskSpace] = []
    private var lastId: UInt = 0

    mutating func writeFile(ofSize size: UInt) throws {
        guard size < 10 else { throw Day9Error.fileSizeTooLarge }
        guard size > 0 else { throw Day9Error.fileEmpty }
        let file = File(id: lastId, size: size)
        content.append(.file(file))
        lastId += 1
    }

    mutating func moveFilePointer(by offset: UInt) throws {
        guard offset < 10 else { throw Day9Error.writeOffsetTooLarge }
        guard offset > 0 else { return }
        content.append(.freeSpace(size: offset))
    }

    func defrag() -> CleanDisk {
        var resultDisk = CleanDisk()
        var allChunks = content.flatMap { diskSpace in
            if let file = diskSpace[case: \.file] {
                return Array(repeating: FileChunk(id: file.id), count: Int(file.size))
            }
            return []
        }
        for diskSpace in content {
            let size = min(Int(diskSpace.size), allChunks.count)
            switch diskSpace {
            case .file:
                resultDisk.appendChunks(Array(allChunks.prefix(size)))
                allChunks.removeFirst(size)
            case .freeSpace:
                resultDisk.appendChunks(Array(allChunks.suffix(size).reversed()))
                allChunks.removeLast(size)
            }
        }
        return resultDisk
    }
}

@CasePathable
enum DiskSpace: Equatable {
    case file(File)
    case freeSpace(size: UInt)

    var size: UInt {
        switch self {
        case let .file(file):
            file.size
        case let .freeSpace(size):
            size
        }
    }
}

struct File: Identifiable, Equatable {
    let id: UInt
    let size: UInt
}

struct CleanDisk: Equatable {
    private(set) var chunks: [FileChunk] = []

    func checksum() -> Int {
        chunks.enumerated().reduce(into: 0) { sum, element in
            let (index, chunk) = element
            sum += index * Int(chunk.id)
        }
    }

    mutating func appendChunk(_ chunk: FileChunk) {
        chunks.append(chunk)
    }

    mutating func append(_ count: UInt, chunk: FileChunk) {
        appendChunks(Array(repeating: chunk, count: Int(count)))
    }

    mutating func appendChunks(_ chunks: [FileChunk]) {
        self.chunks += chunks
    }
}

struct FileChunk: Identifiable, Equatable {
    let id: UInt
}
