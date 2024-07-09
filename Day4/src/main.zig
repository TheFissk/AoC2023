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
    var answer: u32 = 0;

    var cardList = ArrayList(u32).init(alloc);
    defer cardList.deinit();

    var idx: usize = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(alloc, '\r', 1024)) |card| : (idx += 1) {
        defer alloc.free(card);
        const score = try scoreCard(card, alloc);

        if (cardList.items.len < idx + 1 + score) {
            const newEle = try cardList.addManyAsSlice(idx + 1 + score - cardList.items.len);
            for (newEle) |*ele| ele.* = 1;
        }

        for (cardList.items[idx + 1 .. idx + 1 + score]) |*item| item.* += 1 * cardList.items[idx];
        answer += cardList.items[idx];
    }
    return answer;
}

fn parseGroup(arr: []const u8, alloc: mem.Allocator) !ArrayList(u32) {
    var out = ArrayList(u32).init(alloc);

    // std.log.err("Parsing {any}", .{arr});
    var tokens = mem.splitAny(u8, arr, " ");
    while (tokens.next()) |tok| {
        const num = std.fmt.parseUnsigned(u32, tok, 10) catch continue;
        try out.append(num);
    }

    return out;
}

fn scoreCard(card: []const u8, alloc: mem.Allocator) !u5 {
    //slice off the left hand side of the string
    const start = for (card, 0..) |character, index| {
        if (character == ':') {
            break index;
        }
    } else unreachable;

    var tokenized = mem.tokenizeScalar(u8, card[start..], '|');
    //get the winning numbers in a nice array
    const winningNums = try parseGroup(tokenized.next() orelse unreachable, alloc);
    defer winningNums.deinit();

    const ourNums = try parseGroup(tokenized.next() orelse unreachable, alloc);
    defer ourNums.deinit();

    var matches: u5 = 0;

    outer: for (ourNums.items) |our| {
        for (winningNums.items) |winning| {
            if (our == winning) {
                matches += 1;
                continue :outer;
            }
        }
    }
    return matches;
}

pub fn doPartOne(path: []const u8, alloc: mem.Allocator) !u32 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();
    var answer: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(alloc, '\r', 1024)) |card| {
        defer alloc.free(card);
        answer += @as(u32, 1) << try scoreCard(card, alloc) >> 1;
    }
    return answer;
}

test "Part 1 Test" {
    const alloc = std.testing.allocator;
    const expected: u32 = 13;
    const actual = try doPartOne("test.txt", alloc);
    try testing.expectEqual(expected, actual);
}

test "parse Group" {
    const alloc = std.testing.allocator;

    const answer = try parseGroup(" 32 16 88 52 ", alloc);
    defer answer.deinit();
    const expected = [_]u32{ 32, 16, 88, 52 };

    for (answer.items, expected) |an, exp| {
        try testing.expectEqual(exp, an);
    }
}

test "parse with carriage return" {
    const alloc = std.testing.allocator;

    const answer = try parseGroup(" 32 16 88 52", alloc);
    defer answer.deinit();
    const expected = [_]u32{ 32, 16, 88, 52 };

    try testing.expectEqual(expected.len, answer.items.len);
    for (answer.items, expected) |an, exp| {
        try testing.expectEqual(exp, an);
    }
}

test "parse Group Card 3 winning" {
    const alloc = std.testing.allocator;

    const answer = try parseGroup(" 1 21 53 59 44 ", alloc);
    defer answer.deinit();
    const expected = [_]u32{ 1, 21, 53, 59, 44 };

    try testing.expectEqual(expected.len, answer.items.len);
    for (answer.items, expected) |an, exp| {
        try testing.expectEqual(exp, an);
    }
}
test "parse Group Card 3 nums" {
    const alloc = std.testing.allocator;

    const answer = try parseGroup("69 82 63 72 16 21 14  1", alloc);
    defer answer.deinit();
    const expected = [_]u32{ 69, 82, 63, 72, 16, 21, 14, 1 };

    testing.expectEqual(expected.len, answer.items.len) catch |err| {
        for (answer.items, 0..) |item, idx| {
            std.log.err("{d}: {d}", .{ idx, item });
        }
        return err;
    };
    for (answer.items, expected) |an, exp| {
        try testing.expectEqual(exp, an);
    }
}

test "Test known cards 1 by 1" {
    const alloc = std.testing.allocator;

    const cards = [_][]const u8{
        "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53",
        "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19",
        "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1",
        "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83",
        "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36",
        "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11",
    };
    const expectedArr = [_]u32{ 4, 2, 2, 1, 0, 0 };

    for (cards, expectedArr, 1..) |card, expected, idx| {
        const actual = try scoreCard(card, alloc);
        testing.expectEqual(expected, actual) catch {
            std.log.err("Card {d}", .{idx});
        };
    }
}

test "Part 2 Test" {
    const alloc = std.testing.allocator;
    const actual: u32 = try doPartTwo("test.txt", alloc);
    const expected: u32 = 30;
    try testing.expectEqual(expected, actual);
}
