const std = @import("std");
const nanoTimestamp = std.time.nanoTimestamp;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
pub const allocator = arena.allocator();

pub fn splitLines(data: []const u8) [][]const u8 {
    const line_count = count(u8, data, '\n');
    var split = alloc([]const u8, line_count);

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

    const ns_per_ms: f64 = std.time.ns_per_ms;

    var start_time = nanoTimestamp();
    const processed_input = process_input(input);
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;

    start_time = nanoTimestamp();
    const part1_result = part1(processed_input);
    const part1_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;

    start_time = nanoTimestamp();
    const part2_result = part2(processed_input);
    const part2_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;

    std.debug.print(switch (U) {
        []const u8 => "{d}/{d}:\n- Input: {d:.2}ms\n- Part 1: {s} ({d:.2}ms / {d:.2}ms)\n- Part 2: {s} ({d:.2}ms / {d:.2}ms)\n",
        else => "{d}/{d}:\n- Input: {d:.2}ms\n- Part 1: {} ({d:.2}ms / {d:.2}ms)\n- Part 2: {} ({d:.2}ms / {d:.2}ms)\n",
    }, .{
        year,
        day,
        input_time,
        part1_result,
        part1_time,
        input_time + part1_time,
        part2_result,
        part2_time,
        input_time + part2_time,
    });

    arena.deinit();
}

pub fn count(comptime T: type, haystack: []const T, needle: T) usize {
    var total: usize = 0;

    for (haystack) |element| {
        if (element == needle)
            total += 1;
    }

    return total;
}

// Error handling? Never heard of him
pub fn parseInt(comptime T: type, buf: []const u8) T {
    return std.fmt.parseInt(T, buf, 10) catch unreachable;
}

pub fn alloc(comptime T: type, size: usize) []T {
    return allocator.alloc(T, size) catch unreachable;
}
