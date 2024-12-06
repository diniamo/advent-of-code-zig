const std = @import("std");
const utils = @import("utils");

const Tile = enum {
    Empty,
    Obstacle,
    Guard,
};

const InputType = struct {
    tiles: [][]Tile,
    start_row: isize,
    start_col: isize,
};
const ReturnType = usize;

fn processInput(data: []const u8) InputType {
    var input = InputType{
        .tiles = utils.alloc([]Tile, utils.count(u8, data, '\n')),
        .start_row = undefined,
        .start_col = undefined,
    };

    var iter = std.mem.splitScalar(u8, data, '\n');

    var row: usize = 0;
    while (iter.next()) |line| : (row += 1) {
        for (0.., line) |col, char| {
            input.tiles[row][col] = switch (char) {
                '.' => Tile.Empty,
                '#' => Tile.Obstacle,
                '^' => x: {
                    input.start_row = @intCast(row);
                    input.start_col = @intCast(col);

                    break :x Tile.Guard;
                },
                else => unreachable,
            };
        }
    }

    return input;
}

fn part1(input: InputType) ReturnType {
    var count: usize = 0;

    var row = input.start_row;
    var col = input.start_col;

    var row_step: isize = -1;
    var col_step: isize = 0;

    while (true) {
        count += 1;

        const row_new = row + row_step;
        const col_new = col + col_step;

        if (row_new < 0 or row_new >= input.tiles.len or col_new < 0 or col_new > input.tiles[row].len)
            break
        else if (input.tiles[row_new] == Tile.Obstacle) {
            if (col_step == 0) {
                col_step = -row_step;
                row_step = 0;
            } else {
                row_step = col_step;
                col_step = 0;
            }
        } else {
            row = row_new;
            col = col_new;
        }
    }

    return count;
}

fn part2(input: InputType) ReturnType {
    _ = input;
    return "";
}

pub fn main() !void {
    utils.run(2024, 6, InputType, ReturnType, processInput, part1, part2);
}
