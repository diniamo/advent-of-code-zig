const std = @import("std");
const nanoTimestamp = std.time.nanoTimestamp;

pub fn run(comptime year: u12, comptime day: u5, comptime part1: fn (input: []const u8) []const u8, comptime part2: fn (input: []const u8) []const u8) void {
    const input = @embedFile(std.fmt.comptimePrint("{d}/input/{d}.txt", .{ year, day }));

    var start_time = nanoTimestamp();
    const part1_result = part1(input);
    const part1_time: f128 = @as(f128, @floatFromInt(nanoTimestamp() - start_time)) / @as(f128, 10e5);

    start_time = nanoTimestamp();
    const part2_result = part2(input);
    const part2_time = @as(f128, @floatFromInt(nanoTimestamp() - start_time)) / @as(f128, 10e5);

    std.debug.print("{d}/{d}:\n- {d:.2}ms -> {s}\n- {d:.2}ms -> {s}\n", .{ year, day, part1_time, part1_result, part2_time, part2_result });
}
