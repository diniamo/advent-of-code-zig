const std = @import("std");
const utils = @import("utils");

const InputType = [][]const u8;
const ReturnType = []const u8;

fn processInput(data: []const u8) InputType {
    return utils.splitLines(data);
}

fn part1(input: InputType) ReturnType {
    _ = input;
    return "";
}

fn part2(input: InputType) ReturnType {
    _ = input;
    return "";
}

pub fn main() !void {
    utils.run(@year@, @day@, InputType, ReturnType, processInput, part1, part2);
}
