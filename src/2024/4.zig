const std = @import("std");
const utils = @import("utils");

const InputType = [][]const u8;
const ReturnType = usize;

fn processInput(data: []const u8) InputType {
    return utils.splitLines(data);
}

fn part1(input: InputType) ReturnType {
    var count: usize = 0;

    for (0.., input) |row, line| {
        for (0.., line) |col, c| {
            if (c != 'X') continue;

            const up = row >= 3;
            const right = col < (line.len - 3);
            const down = row < (input.len - 3);
            const left = col >= 3;

            if (up   and left  and input[row - 1][col - 1] == 'M' and input[row - 2][col - 2] == 'A' and input[row - 3][col - 3] == 'S') count += 1;
            if (up             and input[row - 1][col    ] == 'M' and input[row - 2][col    ] == 'A' and input[row - 3][col    ] == 'S') count += 1;
            if (up   and right and input[row - 1][col + 1] == 'M' and input[row - 2][col + 2] == 'A' and input[row - 3][col + 3] == 'S') count += 1;
            if (         right and input[row    ][col + 1] == 'M' and input[row    ][col + 2] == 'A' and input[row    ][col + 3] == 'S') count += 1;
            if (down and right and input[row + 1][col + 1] == 'M' and input[row + 2][col + 2] == 'A' and input[row + 3][col + 3] == 'S') count += 1;
            if (down           and input[row + 1][col    ] == 'M' and input[row + 2][col    ] == 'A' and input[row + 3][col    ] == 'S') count += 1;
            if (down and left  and input[row + 1][col - 1] == 'M' and input[row + 2][col - 2] == 'A' and input[row + 3][col - 3] == 'S') count += 1;
            if (         left  and input[row    ][col - 1] == 'M' and input[row    ][col - 2] == 'A' and input[row    ][col - 3] == 'S') count += 1;
        }
    }

    return count;
}

fn part2(input: InputType) ReturnType {
    var count: usize = 0;

    for (0.., input) |row, line| {
        for (0.., line) |col, c| {
            if (c != 'A' or row < 1 or row >= (input.len - 1) or col < 1 or col >= (line.len - 1)) continue;

            if          (input[row - 1][col - 1] == 'M') {
                if      (input[row - 1][col + 1] == 'M' and input[row + 1][col - 1] == 'S' and input[row + 1][col + 1] == 'S') count += 1
                else if (input[row + 1][col - 1] == 'M' and input[row - 1][col + 1] == 'S' and input[row + 1][col + 1] == 'S') count += 1;
            } else if   (input[row + 1][col + 1] == 'M') {
                if      (input[row - 1][col + 1] == 'M' and input[row - 1][col - 1] == 'S' and input[row + 1][col - 1] == 'S') count += 1
                else if (input[row + 1][col - 1] == 'M' and input[row - 1][col - 1] == 'S' and input[row - 1][col + 1] == 'S') count += 1;
            }
        }
    }

    return count;
}

pub fn main() !void {
    utils.run(2024, 4, InputType, ReturnType, processInput, part1, part2);
}

test "part 2 example" {
    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    try std.testing.expect(part2(processInput(input)) == 9);
}
