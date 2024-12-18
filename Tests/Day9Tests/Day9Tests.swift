import CustomDump
@testable import Day9
import Testing

struct Day9Tests {
    let inputPart = "2333133121414131402"

    @Test("A DiskChunk should have a file case with an id property set via init")
    func diskChunkFileCaseTest() {
        let chunk1 = DiskChunk.file(id: 1)
        if case let .file(id) = chunk1 {
            #expect(id == 1)
        } else {
            Issue.record("chunk1 should be a file")
        }

        let chunk2 = DiskChunk.file(id: 42)
        if case let .file(id) = chunk2 {
            #expect(id == 42)
        } else {
            Issue.record("chunk2 should be a file")
        }

        let chunk3 = DiskChunk.file(id: 0)
        if case let .file(id) = chunk3 {
            #expect(id == 0)
        } else {
            Issue.record("chunk3 should be a file")
        }
    }

    @Test("A CleanDisk should have a chunks property of type [DiskChunk] initialized as empty")
    func cleanDiskChunksPropertyTest() {
        let disk = CleanDisk()
        expectNoDifference(disk.chunks, [])
    }

    @Test("A CleanDisk should have an appendChunk method that appends a DiskChunk to its chunks property")
    func cleanDiskAppendChunkTest() {
        var disk = CleanDisk()
        let chunk1 = DiskChunk.file(id: 1)
        let chunk2 = DiskChunk.file(id: 2)
        let chunk3 = DiskChunk.file(id: 3)

        disk.appendChunk(chunk1)
        expectNoDifference(disk.chunks, [chunk1])

        disk.appendChunk(chunk2)
        expectNoDifference(disk.chunks, [chunk1, chunk2])

        disk.appendChunk(chunk3)
        expectNoDifference(disk.chunks, [chunk1, chunk2, chunk3])
    }

    @Test("A CleanDisk should have an append method that appends a DiskChunk n times to its chunks property")
    func cleanDiskAppendNTimesTest() {
        var disk = CleanDisk()
        let chunk = DiskChunk.file(id: 42)

        disk.append(0, chunk: chunk)
        expectNoDifference(disk.chunks, [])

        disk.append(1, chunk: chunk)
        expectNoDifference(disk.chunks, [chunk])

        disk.append(3, chunk: chunk)
        expectNoDifference(disk.chunks, [chunk, chunk, chunk, chunk])

        let chunk2 = DiskChunk.file(id: 7)
        disk.append(2, chunk: chunk2)
        expectNoDifference(disk.chunks, [chunk, chunk, chunk, chunk, chunk2, chunk2])
    }

    @Test("A CleanDisk should have an appendChunks method that appends multiple DiskChunks at once")
    func cleanDiskAppendChunksTest() {
        var disk = CleanDisk()
        let chunk1 = DiskChunk.file(id: 1)
        let chunk2 = DiskChunk.file(id: 2)
        let chunk3 = DiskChunk.file(id: 3)
        let chunks = [chunk1, chunk2, chunk3]

        disk.appendChunks(chunks)
        expectNoDifference(disk.chunks, chunks)

        let chunk4 = DiskChunk.file(id: 4)
        let chunk5 = DiskChunk.file(id: 5)
        let moreChunks = [chunk4, chunk5]

        disk.appendChunks(moreChunks)
        expectNoDifference(disk.chunks, chunks + moreChunks)

        disk.appendChunks([])
        expectNoDifference(disk.chunks, chunks + moreChunks)
    }

    @Test("A CleanDisk should have a checksum method that returns the sum of each chunk index multiplied by its DiskChunk id")
    func cleanDiskChecksumTest() {
        var disk = CleanDisk()
        let chunk1 = DiskChunk.file(id: 1)
        let chunk2 = DiskChunk.file(id: 2)
        let chunk3 = DiskChunk.file(id: 3)

        disk.appendChunk(chunk1)
        #expect(disk.checksum() == 0) // 0 * 1 (index 0 * id 1)

        disk.appendChunk(chunk2)
        #expect(disk.checksum() == 2) // (0 * 1) + (1 * 2)

        disk.appendChunk(chunk3)
        #expect(disk.checksum() == 8) // (0 * 1) + (1 * 2) + (2 * 3)
    }

    @Test("A File should have id and size properties of type UInt that should be set at init")
    func filePropertiesTest() {
        let file1 = File(id: 1, size: 10)
        #expect(file1.id == 1)
        #expect(file1.size == 10)

        let file2 = File(id: 42, size: 100)
        #expect(file2.id == 42)
        #expect(file2.size == 100)

        let file3 = File(id: 0, size: 0)
        #expect(file3.id == 0)
        #expect(file3.size == 0)
    }

    @Test("DiskSpace should have a file case with an associated File object")
    func diskSpaceFileTest() {
        let file = File(id: 42, size: 100)
        let diskSpace = DiskSpace.file(file)

        if case let .file(storedFile) = diskSpace {
            #expect(storedFile.id == file.id)
            #expect(storedFile.size == file.size)
        } else {
            Issue.record("DiskSpace should be a .file case")
        }
    }

    @Test("DiskSpace should have a freeSpace case with an associated size value of type UInt")
    func diskSpaceFreeSpaceTest() {
        let diskSpace = DiskSpace.freeSpace(size: 100)

        if case let .freeSpace(size) = diskSpace {
            #expect(size == 100)
        } else {
            Issue.record("DiskSpace should be a .freeSpace case")
        }
    }

    @Test("DiskSpace should have a computed property size that returns the size of each case")
    func diskSpaceSizeTest() {
        let file = File(id: 42, size: 100)
        let fileDiskSpace = DiskSpace.file(file)
        #expect(fileDiskSpace.size == 100)

        let freeDiskSpace = DiskSpace.freeSpace(size: 50)
        #expect(freeDiskSpace.size == 50)
    }

    @Test("FragmentedDisk should have a content property of type [DiskSpace] that is empty at init")
    func fragmentedDiskContentTest() {
        let disk = FragmentedDisk()
        #expect(disk.content.isEmpty)
    }

    @Test("FragmentedDisk should have a writeFile method that creates a file with incremental id and given size")
    func fragmentedDiskWriteFileTest() throws {
        var disk = FragmentedDisk()

        try disk.writeFile(ofSize: 5)
        #expect(disk.content.count == 1)
        if case let .file(file) = disk.content[0] {
            #expect(file.id == 0)
            #expect(file.size == 5)
        } else {
            Issue.record("First disk space should be a file")
        }

        try disk.writeFile(ofSize: 3)
        #expect(disk.content.count == 2)
        if case let .file(file) = disk.content[1] {
            #expect(file.id == 1)
            #expect(file.size == 3)
        } else {
            Issue.record("Second disk space should be a file")
        }
    }

    @Test("FragmentedDisk.writeFile should throw a Day9Error.fileSizeTooLarge when given size argument is greater than 9")
    func fragmentedDiskWriteFileTooLargeTest() throws {
        var disk = FragmentedDisk()

        // Should not throw with size 9
        try disk.writeFile(ofSize: 9)

        #expect {
            try disk.writeFile(ofSize: 10)
        } throws: { error in
            (error as? Day9Error) == Day9Error.fileSizeTooLarge
        }
    }

    @Test("FragmentedDisk.writeFile should throw a Day9Error.fileEmpty when given size argument is 0")
    func fragmentedDiskWriteFileEmptyTest() throws {
        var disk = FragmentedDisk()

        // Should not throw with size 1
        try disk.writeFile(ofSize: 1)

        #expect {
            try disk.writeFile(ofSize: 0)
        } throws: { error in
            (error as? Day9Error) == Day9Error.fileEmpty
        }
    }

    @Test("FragmentedDisk.moveFilePointer should add a free space with size equal to the given offset")
    func fragmentedDiskMoveFilePointerTest() throws {
        var disk = FragmentedDisk()

        try disk.moveFilePointer(by: 3)
        #expect(disk.content.count == 1)
        if case let .freeSpace(size) = disk.content[0] {
            #expect(size == 3)
        } else {
            Issue.record("First disk space should be free space")
        }

        try disk.moveFilePointer(by: 5)
        #expect(disk.content.count == 2)
        if case let .freeSpace(size) = disk.content[1] {
            #expect(size == 5)
        } else {
            Issue.record("Second disk space should be free space")
        }

        try disk.moveFilePointer(by: 1)
        #expect(disk.content.count == 3)
        if case let .freeSpace(size) = disk.content[2] {
            #expect(size == 1)
        } else {
            Issue.record("Third disk space should be free space")
        }
    }

    @Test("FragmentedDisk.moveFilePointer should add nothing when offset is 0")
    func fragmentedDiskMoveFilePointerZeroTest() throws {
        var disk = FragmentedDisk()

        try disk.moveFilePointer(by: 0)
        #expect(disk.content.count == 0)

        try disk.writeFile(ofSize: 1)
        try disk.moveFilePointer(by: 0)
        #expect(disk.content.count == 1)
    }

    @Test("FragmentedDisk.moveFilePointer should throw a Day9Error.writeOffsetTooLarge when given offset is greater than 9")
    func fragmentedDiskMoveFilePointerTooLargeTest() throws {
        var disk = FragmentedDisk()

        // Should not throw with offset 9
        try disk.moveFilePointer(by: 9)

        #expect {
            try disk.moveFilePointer(by: 10)
        } throws: { error in
            (error as? Day9Error) == Day9Error.writeOffsetTooLarge
        }
    }

    @Test("Day9.readFragmentedDisk should parse input string into a FragmentedDisk with files and offsets")
    func readFragmentedDiskTest() throws {
        let input = "1023456789"
        let disk = try Day9().readFragmentedDisk(from: input)

        expectNoDifference(disk.content, [
            .file(File(id: 0, size: 1)),
            .file(File(id: 1, size: 2)),
            .freeSpace(size: 3),
            .file(File(id: 2, size: 4)),
            .freeSpace(size: 5),
            .file(File(id: 3, size: 6)),
            .freeSpace(size: 7),
            .file(File(id: 4, size: 8)),
            .freeSpace(size: 9),
        ])
    }

    @Test("Day9.readFragmentedDisk should throw Day9Error.invalidSector when input contains non-digit characters")
    func readFragmentedDiskInvalidInputTest() throws {
        let invalidInputs = ["1a23", "12.3", "1-23", "12 3"]

        for input in invalidInputs {
            #expect {
                try Day9().readFragmentedDisk(from: input)
            } throws: { error in
                (error as? Day9Error) == Day9Error.invalidSector
            }
        }
    }

    @Test("FragmentedDisk.defrag should return a CleanDisk where all the gaps are filled with FileChunks from the end of the fragmented disk")
    func defragTest() throws {
        var fragmentedDisk = FragmentedDisk()
        try fragmentedDisk.writeFile(ofSize: 1)
        try fragmentedDisk.moveFilePointer(by: 2)
        try fragmentedDisk.writeFile(ofSize: 3)
        try fragmentedDisk.moveFilePointer(by: 4)
        try fragmentedDisk.writeFile(ofSize: 5)

        var expectedCleanDisk = CleanDisk()
        expectedCleanDisk.appendChunk(DiskChunk.file(id: 0))
        expectedCleanDisk.append(2, chunk: DiskChunk.file(id: 2))
        expectedCleanDisk.append(3, chunk: DiskChunk.file(id: 1))
        expectedCleanDisk.append(3, chunk: DiskChunk.file(id: 2))

        expectNoDifference(fragmentedDisk.defrag(), expectedCleanDisk)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day9().runPart1(with: inputPart)
        #expect(part1 == "1928")
    }

    @Test("DiskChunk should have a computed property checksum that returns the file id")
    func diskChunkChecksumTest() {
        let chunk1 = DiskChunk.file(id: 42)
        #expect(chunk1.checksum == 42)

        let chunk2 = DiskChunk.file(id: 0)
        #expect(chunk2.checksum == 0)

        let chunk3 = DiskChunk.file(id: 100)
        #expect(chunk3.checksum == 100)
    }

    @Test("DiskChunk should have a free case for which checksum returns 0")
    func diskChunkFreeCaseTest() {
        let chunk = DiskChunk.free
        #expect(chunk.checksum == 0)
    }

    @Test("Array should have a method removeLastOccurrence that removes and returns only the last element equal to the given one")
    func removeLastOccurrenceTest() {
        var array = [1, 2, 3, 2, 4, 2, 5]
        let removed = array.removeLastOccurrence(of: 2)

        #expect(removed == 2)
        #expect(array == [1, 2, 3, 2, 4, 5])

        let removed2 = array.removeLastOccurrence(of: 2)
        #expect(removed2 == 2)
        #expect(array == [1, 2, 3, 4, 5])

        let removed3 = array.removeLastOccurrence(of: 2)
        #expect(removed3 == 2)
        #expect(array == [1, 3, 4, 5])

        let removed4 = array.removeLastOccurrence(of: 2)
        #expect(removed4 == nil)
        #expect(array == [1, 3, 4, 5])
    }

    @Test("Array of DiskSpace should have a method moveInFirstFittingFreeSpaceIfAvailable that moves a file to first fitting free space")
    func moveInFirstFittingFreeSpaceTest() {
        let diskSpaces: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .freeSpace(size: 4),
            .file(File(id: 1, size: 3)),
            .freeSpace(size: 2),
            .file(File(id: 2, size: 2)),
        ]

        let file = File(id: 2, size: 2)
        let result = diskSpaces.moveInFirstFittingFreeSpaceIfAvailable(file: file)

        let expected: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .file(File(id: 2, size: 2)),
            .freeSpace(size: 2),
            .file(File(id: 1, size: 3)),
            .freeSpace(size: 2),
            .freeSpace(size: 2),
        ]

        expectNoDifference(result, expected)

        // Test when free space is exactly file size
        let diskSpaces2: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .freeSpace(size: 3),
            .file(File(id: 1, size: 3)),
            .file(File(id: 2, size: 3)),
        ]

        let file2 = File(id: 2, size: 3)
        let result2 = diskSpaces2.moveInFirstFittingFreeSpaceIfAvailable(file: file2)

        let expected2: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .file(File(id: 2, size: 3)),
            .file(File(id: 1, size: 3)),
            .freeSpace(size: 3),
        ]

        expectNoDifference(result2, expected2)

        // Test when no fitting free space available
        let diskSpaces3: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .freeSpace(size: 1),
            .file(File(id: 1, size: 3)),
            .file(File(id: 2, size: 3)),
        ]

        let file3 = File(id: 2, size: 3)
        let result3 = diskSpaces3.moveInFirstFittingFreeSpaceIfAvailable(file: file3)

        expectNoDifference(result3, diskSpaces3)
    }
    @Test("Array<DiskSpace>.coalesceAllFreeSpaces() should combine contiguous free spaces")
    func coalesceAllFreeSpacesTest() {
        let diskSpaces: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .freeSpace(size: 3),
            .freeSpace(size: 2),
            .file(File(id: 1, size: 3)),
            .freeSpace(size: 1),
            .freeSpace(size: 2),
            .freeSpace(size: 3),
            .file(File(id: 2, size: 2))
        ]

        let result = diskSpaces.coalesceAllFreeSpaces()

        let expected: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .freeSpace(size: 5),
            .file(File(id: 1, size: 3)),
            .freeSpace(size: 6),
            .file(File(id: 2, size: 2))
        ]

        expectNoDifference(result, expected)

        // Test with no contiguous free spaces
        let diskSpaces2: [DiskSpace] = [
            .file(File(id: 0, size: 2)),
            .freeSpace(size: 3),
            .file(File(id: 1, size: 3)),
            .freeSpace(size: 2),
            .file(File(id: 2, size: 2))
        ]

        let result2 = diskSpaces2.coalesceAllFreeSpaces()
        expectNoDifference(result2, diskSpaces2)

        // Test with only free spaces
        let diskSpaces3: [DiskSpace] = [
            .freeSpace(size: 1),
            .freeSpace(size: 2),
            .freeSpace(size: 3)
        ]

        let result3 = diskSpaces3.coalesceAllFreeSpaces()
        let expected3: [DiskSpace] = [.freeSpace(size: 6)]

        expectNoDifference(result3, expected3)
    }

    @Test("FragmentedDisk.wholeFileDefrag should return a CleanDisk where all the gaps are filled with FileChunks of whole files from the end of the fragmented disk when possible")
    func wholeFileDefragTest() throws {
        var fragmentedDisk = FragmentedDisk()
        try fragmentedDisk.writeFile(ofSize: 2)
        try fragmentedDisk.moveFilePointer(by: 3)
        try fragmentedDisk.writeFile(ofSize: 3)
        try fragmentedDisk.moveFilePointer(by: 3)
        try fragmentedDisk.writeFile(ofSize: 1)
        try fragmentedDisk.moveFilePointer(by: 3)
        try fragmentedDisk.writeFile(ofSize: 3)
        try fragmentedDisk.moveFilePointer(by: 1)
        try fragmentedDisk.writeFile(ofSize: 2)
        try fragmentedDisk.moveFilePointer(by: 1)
        try fragmentedDisk.writeFile(ofSize: 4)
        try fragmentedDisk.moveFilePointer(by: 1)
        try fragmentedDisk.writeFile(ofSize: 4)
        try fragmentedDisk.moveFilePointer(by: 1)
        try fragmentedDisk.writeFile(ofSize: 3)
        try fragmentedDisk.moveFilePointer(by: 1)
        try fragmentedDisk.writeFile(ofSize: 4)
        try fragmentedDisk.writeFile(ofSize: 2)

        var expectedCleanDisk = CleanDisk()
        expectedCleanDisk.append(2, chunk: .file(id: 0))
        expectedCleanDisk.append(2, chunk: .file(id: 9))
        expectedCleanDisk.append(1, chunk: .file(id: 2))
        expectedCleanDisk.append(3, chunk: .file(id: 1))
        expectedCleanDisk.append(3, chunk: .file(id: 7))
        expectedCleanDisk.appendChunk(.free)
        expectedCleanDisk.append(2, chunk: .file(id: 4))
        expectedCleanDisk.appendChunk(.free)
        expectedCleanDisk.append(3, chunk: .file(id: 3))
        expectedCleanDisk.append(4, chunk: .free)
        expectedCleanDisk.append(4, chunk: .file(id: 5))
        expectedCleanDisk.appendChunk(.free)
        expectedCleanDisk.append(4, chunk: .file(id: 6))
        expectedCleanDisk.append(5, chunk: .free)
        expectedCleanDisk.append(4, chunk: .file(id: 8))
        expectedCleanDisk.append(2, chunk: .free)

        expectNoDifference(fragmentedDisk.wholeFileDefrag(), expectedCleanDisk)
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day9().runPart2(with: inputPart)
        #expect(part2 == "2858")
    }
}
