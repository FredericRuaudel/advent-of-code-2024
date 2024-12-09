import CustomDump
@testable import Day9
import Testing

struct Day9Tests {
    let inputPart = "2333133121414131402"

    @Test("A FileChunk should have an id property set via init")
    func fileChunkIdPropertyTest() {
        let chunk1 = FileChunk(id: 1)
        #expect(chunk1.id == 1)

        let chunk2 = FileChunk(id: 42)
        #expect(chunk2.id == 42)

        let chunk3 = FileChunk(id: 0)
        #expect(chunk3.id == 0)
    }

    @Test("A CleanDisk should have a chunks property of type [FileChunk] initialized as empty")
    func cleanDiskChunksPropertyTest() {
        let disk = CleanDisk()
        expectNoDifference(disk.chunks, [])
    }

    @Test("A CleanDisk should have an appendChunk method that appends a FileChunk to its chunks property")
    func cleanDiskAppendChunkTest() {
        var disk = CleanDisk()
        let chunk1 = FileChunk(id: 1)
        let chunk2 = FileChunk(id: 2)
        let chunk3 = FileChunk(id: 3)

        disk.appendChunk(chunk1)
        expectNoDifference(disk.chunks, [chunk1])

        disk.appendChunk(chunk2)
        expectNoDifference(disk.chunks, [chunk1, chunk2])

        disk.appendChunk(chunk3)
        expectNoDifference(disk.chunks, [chunk1, chunk2, chunk3])
    }

    @Test("A CleanDisk should have an append method that appends a FileChunk n times to its chunks property")
    func cleanDiskAppendNTimesTest() {
        var disk = CleanDisk()
        let chunk = FileChunk(id: 42)

        disk.append(0, chunk: chunk)
        expectNoDifference(disk.chunks, [])

        disk.append(1, chunk: chunk)
        expectNoDifference(disk.chunks, [chunk])

        disk.append(3, chunk: chunk)
        expectNoDifference(disk.chunks, [chunk, chunk, chunk, chunk])

        let chunk2 = FileChunk(id: 7)
        disk.append(2, chunk: chunk2)
        expectNoDifference(disk.chunks, [chunk, chunk, chunk, chunk, chunk2, chunk2])
    }

    @Test("A CleanDisk should have an appendChunks method that appends multiple FileChunks at once")
    func cleanDiskAppendChunksTest() {
        var disk = CleanDisk()
        let chunk1 = FileChunk(id: 1)
        let chunk2 = FileChunk(id: 2)
        let chunk3 = FileChunk(id: 3)
        let chunks = [chunk1, chunk2, chunk3]

        disk.appendChunks(chunks)
        expectNoDifference(disk.chunks, chunks)

        let chunk4 = FileChunk(id: 4)
        let chunk5 = FileChunk(id: 5)
        let moreChunks = [chunk4, chunk5]

        disk.appendChunks(moreChunks)
        expectNoDifference(disk.chunks, chunks + moreChunks)

        disk.appendChunks([])
        expectNoDifference(disk.chunks, chunks + moreChunks)
    }

    @Test("A CleanDisk should have a checksum method that returns the sum of each chunk index multiplied by its FileChunk id")
    func cleanDiskChecksumTest() {
        var disk = CleanDisk()
        let chunk1 = FileChunk(id: 1)
        let chunk2 = FileChunk(id: 2)
        let chunk3 = FileChunk(id: 3)

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
        expectedCleanDisk.appendChunk(FileChunk(id: 0))
        expectedCleanDisk.append(2, chunk: FileChunk(id: 2))
        expectedCleanDisk.append(3, chunk: FileChunk(id: 1))
        expectedCleanDisk.append(3, chunk: FileChunk(id: 2))

        expectNoDifference(fragmentedDisk.defrag(), expectedCleanDisk)
    }

    @Test("Part1 with challenge example input")
    func exampleInputPart1() throws {
        let part1 = try Day9().runPart1(with: inputPart)
        #expect(part1 == "1928")
    }

    @Test("Part2 with challenge example input")
    func exampleInputPart2() throws {
        let part2 = try Day9().runPart2(with: inputPart)
        #expect(part2 == "")
    }
}
