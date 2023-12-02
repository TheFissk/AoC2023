const std = @import("std");
const io = std.io;
const mem = std.mem;
const ArrayList = std.ArrayList;
const ParseIntError = std.fmt.ParseIntError;
const GenericReader = io.GenericReader;
const testing = std.testing;
const expect = testing.expect;

pub fn main() !void {
    const answer = try doPartOne("./input.txt");
    std.debug.print("Answer for Part 1: {}\n", .{answer});
    const part2 = try doPartTwo("./input.txt");
    std.debug.print("Answer for Part 2: {}\n", .{part2});
}

pub fn doPartTwo(path: []const u8) !u32 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var answer: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const left: u32 = for (0..line.len) |idx| {
            if (parseNumber(line, idx)) |value| {
                break value;
            }
        } else 0;
        const right: u32 = for (0..line.len) |i| {
            const idx = line.len - i - 1;
            if (parseNumber(line, idx)) |value| {
                break value;
            }
        } else 0;
        answer += left * 10 + right;
    }
    return answer;
}

pub fn parseNumber(line: []const u8, idx: usize) ?u32 {
    const l: u32 = std.fmt.parseUnsigned(u32, line[idx .. idx + 1], 10) catch 0;
    if (l > 0) return l;
    if (idx + 3 > line.len) return null;
    if (mem.eql(u8, "one", line[idx .. idx + 3])) return 1;
    if (mem.eql(u8, "two", line[idx .. idx + 3])) return 2;
    if (mem.eql(u8, "six", line[idx .. idx + 3])) return 6;
    if (idx + 4 > line.len) return null;
    if (mem.eql(u8, "four", line[idx .. idx + 4])) return 4;
    if (mem.eql(u8, "five", line[idx .. idx + 4])) return 5;
    if (mem.eql(u8, "nine", line[idx .. idx + 4])) return 9;
    if (idx + 5 > line.len) return null;
    if (mem.eql(u8, "three", line[idx .. idx + 5])) return 3;
    if (mem.eql(u8, "seven", line[idx .. idx + 5])) return 7;
    if (mem.eql(u8, "eight", line[idx .. idx + 5])) return 8;
    return null;
}

pub fn doPartOne(path: []const u8) !u32 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var answer: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var right: u32 = 0;

        const left: u32 = for (0..line.len) |idx| {
            break std.fmt.parseUnsigned(u32, line[idx .. idx + 1], 10) catch {
                continue;
            };
        } else 0;
        var i = line.len;
        while (i > 0) {
            i -= 1;
            const tbuf = .{line[i]};
            right = std.fmt.parseUnsigned(u32, &tbuf, 10) catch {
                continue;
            };
            break;
        }
        answer += left * 10 + right;
    }
    return answer;
}

test "Part 1 Test" {
    const answer = try doPartOne("test.txt");
    try expect(142 == answer);
}

test "Part 2 Test" {
    const answer: u32 = try doPartTwo("test2.txt");
    const expected: u32 = 281;
    try testing.expectEqual(expected, answer);
}
