const std = @import("std");
const utils = @import("utils");

const InputType = struct {
    left: []u32,
    right: []u32,
};
const ReturnType = usize;

fn processInput(input: []const u8) InputType {
    const line_count = utils.count(u8, input, '\n');

    var left = utils.gpa.alloc(u32, line_count) catch unreachable;
    var right = utils.gpa.alloc(u32, line_count) catch unreachable;

    var iter = std.mem.splitScalar(u8, input, '\n');
    var i: usize = 0;
    while (iter.next()) |line| : (i += 1) {
        if (line.len == 0) break;

        var split = std.mem.splitSequence(u8, line, "   ");

        left[i] = utils.parseInt(u32, split.next() orelse unreachable);
        right[i] = utils.parseInt(u32, split.next() orelse unreachable);
    }

    return .{
        .left = left,
        .right = right,
    };
}

fn part1(input: InputType) ReturnType {
    std.mem.sort(u32, input.left, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, input.right, {}, comptime std.sort.asc(u32));

    var sum: u64 = 0;
    for (input.left, input.right) |l, r| {
        sum += @abs(@as(i64, l) - @as(i64, r));
    }

    return sum;
}

fn part2(input: InputType) ReturnType {
    var sum: usize = 0;

    for (input.left) |n| {
        sum += n * utils.count(u32, input.right, n);
    }

    return sum;
}

pub fn main() !void {
    utils.run(2024, 1, InputType, ReturnType, processInput, part1, part2);
}

test "part 2" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    const processed_input = processInput(input);
    const result = part2(processed_input);

    try std.testing.expect(result == 31);
}