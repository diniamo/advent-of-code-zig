const std = @import("std");
const nanoTimestamp = std.time.nanoTimestamp;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
pub const allocator = arena.allocator();

pub fn splitLines(data: []const u8) [][]const u8 {
    const line_count = count(u8, data, '\n');
    var split = allocator.alloc([]const u8, line_count);

    var start: usize = 0;
    var i: usize = 0;
    for (0..data.len) |pointer| {
        if (data[pointer] == '\n') {
            split[i] = data[start..pointer];
            i += 1;
            start = pointer + 1;
        }
    }

    return split;
}

pub fn run(
    comptime year: u12,
    comptime day: u5,
    comptime T: type,
    comptime U: type,
    comptime process_input: fn (input: []const u8) T,
    comptime part1: fn (input: T) U,
    comptime part2: fn (input: T) U,
) void {
    const input = @embedFile(std.fmt.comptimePrint("{d}/input/{d}.txt", .{ year, day }));
    const processed_input = process_input(input);

    var start_time = nanoTimestamp();
    const part1_result = part1(processed_input);
    const part1_time: f128 = @as(f128, @floatFromInt(nanoTimestamp() - start_time)) / @as(f128, 10e5);

    start_time = nanoTimestamp();
    const part2_result = part2(processed_input);
    const part2_time = @as(f128, @floatFromInt(nanoTimestamp() - start_time)) / @as(f128, 10e5);

    std.debug.print("{d}/{d}:\n- {d:.2}ms -> {}\n- {d:.2}ms -> {}\n", .{ year, day, part1_time, part1_result, part2_time, part2_result });

    arena.deinit();
}

pub fn parseInt(comptime T: type, buf: []const u8) T {
    return std.fmt.parseInt(T, buf, 10) catch unreachable;
}

pub fn count(comptime T: type, haystack: []const T, needle: T) usize {
    var total: usize = 0;

    for (haystack) |element| {
        if (element == needle)
            total += 1;
    }

    return total;
}
