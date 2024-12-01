const std = @import("std");
const FileLineReader = @import("utils.zig").FileLineReader;
const Result = @import("utils.zig").Result;

pub fn day01(allocator: std.mem.Allocator, reader: *FileLineReader) anyerror!Result {
    var result: Result = std.mem.zeroes(Result);

    var n: u32 = 0;

    var left_arr = std.ArrayList(i32).init(allocator);
    defer left_arr.deinit();

    var right_arr = std.ArrayList(i32).init(allocator);
    defer right_arr.deinit();

    var count_map = std.AutoHashMap(i32, u16).init(allocator);
    defer count_map.deinit();

    while (try reader.next()) |line| : (n += 1) {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const left = try std.fmt.parseInt(i32, it.next().?, 10);
        const right = try std.fmt.parseInt(i32, it.next().?, 10);
        try left_arr.append(left);
        try right_arr.append(right);
    }

    std.sort.pdq(i32, left_arr.items, {}, std.sort.asc(i32));
    std.sort.pdq(i32, right_arr.items, {}, std.sort.asc(i32));

    for (0..n) |i| {
        const count = if (count_map.contains(right_arr.items[i])) count_map.get(right_arr.items[i]).? else 0;
        try count_map.put(right_arr.items[i], count + 1);
    }

    for (0..n) |i| {
        result.part1 += @abs(left_arr.items[i] - right_arr.items[i]);
        const factor = if (count_map.contains(left_arr.items[i])) count_map.get(left_arr.items[i]).? else 0;
        result.part2 += left_arr.items[i] * factor;
    }

    return result;
}

const testResult = @import("utils.zig").testResult;

test "day01 - Part 1" {
    try testResult("day01.txt", day01, .Part1, 11);
}

test "day01 - Part 2" {
    try testResult("day01.txt", day01, .Part2, 31);
}
