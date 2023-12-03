const io = @import("std").io;
const testing = @import("std").testing;
const fs = @import("std").fs;
const mem = @import("std").mem;
const debug = @import("std").debug;
const fmt = @import("std").fmt;

const Bag = struct {
    r: u32 = 0,
    g: u32 = 0,
    b: u32 = 0,
    fn couldBe(self: *const Bag, other_bag: Bag) bool {
        return (self.r <= other_bag.r and self.g <= other_bag.g and self.b <= other_bag.b);
    }
    fn addPull(self: *Bag, pull: []const u8) !void {
        var cubes = mem.tokenizeSequence(u8, pull, " ");
        while (cubes.next()) |cube| {
            const number = try fmt.parseInt(u32, cube, 10);
            const color = cubes.next().?;
            switch (color[0]) {
                'r' => {
                    self.r = if (self.r < number) number else self.r;
                },
                'g' => {
                    self.g = if (self.g < number) number else self.g;
                },
                'b' => {
                    self.b = if (self.b < number) number else self.b;
                },
                else => {},
            }
        }
    }
    fn parseLine(self: *Bag, line: []const u8) !void {
        var dataSplit = mem.splitScalar(u8, line, ':');
        _ = dataSplit.next();
        const game = dataSplit.next().?;
        var pulls = mem.splitScalar(u8, game, ';');
        while (pulls.next()) |pull| {
            try self.addPull(pull);
        }
    }

    fn power(self: *const Bag) u32 {
        return self.r * self.g * self.b;
    }
};

pub fn doPartOne(path: []const u8, bag: Bag) !u32 {
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
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();
    var answer: u32 = 0;
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var thisBag = Bag{};
        try thisBag.parseLine(line);
        answer += thisBag.power();
    }
    return answer;
}

pub fn main() !void {
    const p1 = try doPartOne("./input.txt", Bag{ .r = 12, .g = 13, .b = 14 });
    debug.print("Answer for Part 1: {}\n", .{p1});
    const p2 = try doPartTwo("./input.txt");
    debug.print("Answer for Part 2: {}\n", .{p2});
}

test "str to int" {
    const str = "1"; 
    //"1" => 00110001 => 0x31
    //"2" => 00110010 => 0x32
    //"3" => 00110011 => 0x33
    const num: u8 = str[0];
    debug.print("\r\nWHAT IS THE NUMBER: {d}\r\n", .{num});
    try testing.expect(num == 1);
}

test "Part 1" {
    const expected: u32 = 8;
    try testing.expectEqual(expected, try doPartOne("test.txt", Bag{ .r = 12, .b = 13, .g = 14 }));
}
test "Part 2" {
    const expected: u32 = 2286;
    try testing.expectEqual(expected, try doPartTwo("test.txt"));
}

test "Bag Could Be" {
    const bag_1 = Bag{ .r = 10, .g = 20, .b = 30 };
    const bag_2 = Bag{ .r = 15, .g = 25, .b = 35 };
    const bag_3 = Bag{ .r = 10, .g = 20, .b = 30 };
    const bag_4 = Bag{ .r = 5, .g = 15, .b = 25 };
    try testing.expect(bag_1.couldBe(bag_2));
    try testing.expect(bag_1.couldBe(bag_1));
    try testing.expect(!bag_3.couldBe(bag_4));
    try testing.expect(!bag_2.couldBe(bag_1));
}

test "Bag Builder" {
    var thisBag = Bag{};
    try thisBag.parseLine("Game 39: 2 blue; 4 red; 4 red, 5 green, 1 blue");
    const shouldBe = Bag{ .r = 4, .b = 2, .g = 5 };
    try testing.expectEqual(shouldBe, thisBag);
}
