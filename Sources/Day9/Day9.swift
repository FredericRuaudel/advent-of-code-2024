import CasePaths
import Core

public final class Day9: AoCDay {
    public required init() {}

    public func runPart1(with input: String) throws -> String {
        let fragmentedDisk = try readFragmentedDisk(from: input)
        let cleanedDisk = fragmentedDisk.defrag()
        return cleanedDisk.checksum().asText()
    }

    public func runPart2(with input: String) throws -> String {
        let fragmentedDisk = try readFragmentedDisk(from: input)
        let cleanedDisk = fragmentedDisk.wholeFileDefrag()
        return cleanedDisk.checksum().asText()
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
                return Array(repeating: DiskChunk.file(id: file.id), count: Int(file.size))
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

    func wholeFileDefrag() -> CleanDisk {
        let allFilesFromEndOfDisk = content.reversed().compactMap { $0[case: \.file] }
        var newContent = content
        for file in allFilesFromEndOfDisk {
            newContent = newContent.moveInFirstFittingFreeSpaceIfAvailable(file: file)
            newContent = newContent.coalesceAllFreeSpaces()
        }
        return newContent.reduce(into: CleanDisk()) { resultDisk, diskSpace in
            switch diskSpace {
            case let .file(file):
                resultDisk.append(file.size, chunk: .file(id: file.id))
            case let .freeSpace(size):
                resultDisk.append(size, chunk: .free)
            }
        }
    }
}

extension Array where Element == DiskSpace {
    func moveInFirstFittingFreeSpaceIfAvailable(file: File) -> Self {
        var newContent = self
        let firstFittingFreeSpaceIndex = newContent.firstIndex(where: { diskSpace in
            diskSpace.is(\.freeSpace) && diskSpace.size >= file.size
        })
        if let firstFittingFreeSpaceIndex {
            let removedSpace = newContent.remove(at: firstFittingFreeSpaceIndex)
            var insertedDiskSpaces = [DiskSpace.file(file)]
            if removedSpace.size > file.size {
                insertedDiskSpaces.append(.freeSpace(size: removedSpace.size - file.size))
            }
            newContent.insert(contentsOf: insertedDiskSpaces, at: firstFittingFreeSpaceIndex)
            if let lastIndexOfFile = newContent.lastIndex(of: .file(file)) {
                newContent.remove(at: lastIndexOfFile)
                newContent.insert(.freeSpace(size: file.size), at: lastIndexOfFile)
            }
        }
        return newContent
    }

    func coalesceAllFreeSpaces() -> Self {
        var newContent = Self()
        var contiguousFreeSpacesSize: UInt = 0
        for diskSpace in self {
            switch diskSpace {
            case .file:
                if contiguousFreeSpacesSize > 0 {
                    newContent.append(.freeSpace(size: contiguousFreeSpacesSize))
                    contiguousFreeSpacesSize = 0
                }
                newContent.append(diskSpace)
            case let .freeSpace(size):
                contiguousFreeSpacesSize += size
            }
        }
        if contiguousFreeSpacesSize > 0 {
            newContent.append(.freeSpace(size: contiguousFreeSpacesSize))
        }
        return newContent
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

enum DiskChunk: Equatable {
    case file(id: UInt)
    case free

    var checksum: Int {
        switch self {
        case let .file(id):
            Int(id)
        case .free:
            0
        }
    }
}

struct CleanDisk: Equatable {
    private(set) var chunks: [DiskChunk] = []

    func checksum() -> Int {
        chunks.enumerated().reduce(into: 0) { sum, element in
            let (index, chunk) = element
            sum += index * chunk.checksum
        }
    }

    mutating func appendChunk(_ chunk: DiskChunk) {
        chunks.append(chunk)
    }

    mutating func append(_ count: UInt, chunk: DiskChunk) {
        appendChunks(Array(repeating: chunk, count: Int(count)))
    }

    mutating func appendChunks(_ chunks: [DiskChunk]) {
        self.chunks += chunks
    }
}
