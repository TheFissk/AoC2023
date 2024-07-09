const std = @import("std");
const io = std.io;
const mem = std.mem;
const heap = std.heap;
const ArrayList = std.ArrayList;
const ParseIntError = std.fmt.ParseIntError;
const GenericReader = io.GenericReader;
const testing = std.testing;
const expect = testing.expect;

pub fn main() !void {
    var alloc = heap.GeneralPurposeAllocator(.{}){};
    const answer = try doPartOne("./input.txt", alloc.allocator());
    std.debug.print("Answer for Part 1: {}\n", .{answer});
    const part2 = try doPartTwo("./input.txt", alloc.allocator());
    std.debug.print("Answer for Part 2: {}\n", .{part2});
}

pub fn doPartTwo(path: []const u8, alloc: mem.Allocator) !u32 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();

    while (try in_stream.readUntilDelimiterOrEofAlloc(alloc, '\r', 1024)) |line| {
        defer alloc.free(line);
    }
    return 0;
}

pub fn doPartOne(path: []const u8, alloc: mem.Allocator) !u32 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();

    while (try in_stream.readAllAlloc(alloc, '\r', 1024)) |line| {
        defer alloc.free(line);
    }
    return 0;
}

test "Part 1 Test" {
    const alloc = std.testing.allocator;
    const expected: u32 = 35;
    const actual = try doPartOne("test.txt", alloc);
    try testing.expectEqual(expected, actual);
}

// test "Part 2 Test" {
//     const alloc = std.testing.allocator;
//     const actual: u32 = try doPartTwo("test.txt", alloc);
//     const expected: u32 = 30;
//     try testing.expectEqual(expected, actual);
// }
