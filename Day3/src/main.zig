const io = @import("std").io;
const testing = @import("std").testing;
const fs = @import("std").fs;
const mem = @import("std").mem;
const debug = @import("std").debug;
const fmt = @import("std").fmt;

pub fn doPartOne(path: []const u8) !u32 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();
    var answer: u32 = 0;
    var buf: [1024]u8 = undefined;
    var gameID: u32 = 1;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (gameID += 1) {
        var thisBag = Bag{};
        try thisBag.parseLine(line);
        if (thisBag.couldBe(bag)) {
            answer += gameID;
        }
    }
    return answer;
}

pub fn doPartTwo(path: []const u8) !u32 {
    _ = path;

    return 0;
}

pub fn main() !void {
    const p1 = try doPartOne("./input.txt", Bag{ .r = 12, .g = 13, .b = 14 });
    debug.print("Answer for Part 1: {}\n", .{p1});
    const p2 = try doPartTwo("./input.txt");
    debug.print("Answer for Part 2: {}\n", .{p2});
}

test "Part 1" {
    const expected: u32 = 4361;
    try testing.expectEqual(expected, try doPartOne("test.txt"));
}
// test "Part 2" {
//     const expected: u32 = 2286;
//     try testing.expectEqual(expected, try doPartTwo("test.txt"));
// }
