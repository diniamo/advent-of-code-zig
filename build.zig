const std = @import("std");

fn findHighestEntry(comptime T: type, root_dir: std.fs.Dir, dir_path: []const u8, kind: std.fs.File.Kind) !T {
    var max: ?T = null;

    const dir = try root_dir.openDir(dir_path, .{ .iterate = true });
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != kind) continue;

        const parsed = try std.fmt.parseInt(T, std.fs.path.stem(entry.name), 10);
        if (max == null or parsed > max.?)
            max = parsed;
    }

    return max orelse std.fs.File.OpenError.FileNotFound;
}

fn ensureSource(allocator: std.mem.Allocator, root_dir: std.fs.Dir, year: u12, day: u5) ![]const u8 {
    const path = try std.fmt.allocPrint(allocator, "src/{d}/{d}.zig", .{ year, day });

    root_dir.access(path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            const template_file = try root_dir.openFile("template.zig", .{});
            var template = try template_file.readToEndAlloc(allocator, try template_file.getEndPos());

            template = try std.mem.replaceOwned(u8, allocator, template, "@year@", try std.fmt.allocPrint(allocator, "{d}", .{year}));
            template = try std.mem.replaceOwned(u8, allocator, template, "@day@", try std.fmt.allocPrint(allocator, "{d}", .{day}));

            try root_dir.makePath(try std.fmt.allocPrint(allocator, "src/{d}", .{year}));
            const file = try root_dir.createFile(path, .{});
            try file.writeAll(template);
        },
        else => return err,
    };

    return path;
}

fn ensureInput(allocator: std.mem.Allocator, root_dir: std.fs.Dir, year: u12, day: u5) !void {
    const path = try std.fmt.allocPrint(allocator, "src/{d}/input/{d}.txt", .{ year, day });
    root_dir.access(path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            const token_file = root_dir.openFile("token.txt", .{}) catch std.debug.panic("Root directory does not contain a token.txt file", .{});
            defer token_file.close();
            const token = try token_file.reader().readAllAlloc(allocator, try token_file.getEndPos());

            var client = std.http.Client{ .allocator = allocator };
            defer client.deinit();

            const uri = try std.Uri.parse(try std.fmt.allocPrint(allocator, "https://adventofcode.com/{d}/day/{d}/input", .{ year, day }));
            const headers = [_]std.http.Header{.{ .name = "Cookie", .value = try std.fmt.allocPrint(allocator, "session={s}", .{token}) }};
            var server_header_buffer: [16_384]u8 = undefined;

            var request = try client.open(.GET, uri, .{ .server_header_buffer = &server_header_buffer, .extra_headers = &headers });
            defer request.deinit();

            try request.send();
            try request.finish();
            try request.wait();

            try root_dir.makePath(try std.fmt.allocPrint(allocator, "src/{d}/input", .{year}));
            const file = try root_dir.createFile(path, .{});
            defer file.close();

            var fifo = std.fifo.LinearFifo(u8, .{ .Static = 4096 }).init();
            defer fifo.deinit();

            try fifo.pump(request.reader(), file.writer());
        },
        else => return err,
    };
}

pub fn build(b: *std.Build) !void {
    const root_dir = try std.fs.openDirAbsolute(b.path(".").getPath(b), .{});

    const fast = b.option(bool, "fast", "Optimize for speed") orelse false;
    const year = b.option(u12, "year", "The year to run the day in") orelse findHighestEntry(u12, root_dir, "src", std.fs.File.Kind.directory) catch {
        try b.default_step.addError("Could't detect year, please provide one to complete initialization logic", .{});
        return;
    };
    const day = b.option(u5, "day", "The day to run") orelse findHighestEntry(u5, root_dir, try std.fmt.allocPrint(b.allocator, "src/{d}", .{year}), std.fs.File.Kind.file) catch {
        try b.default_step.addError("Could't detect day, please provide one to complete initialization logic", .{});
        return;
    };

    const root_source_file = b.path(try ensureSource(b.allocator, root_dir, year, day));
    try ensureInput(b.allocator, root_dir, year, day);

    const target = b.host;
    const optimize: std.builtin.OptimizeMode = if (fast) .ReleaseFast else .Debug;
    const utils = .{ .root_source_file = b.path("src/utils.zig") };

    const exe = b.addExecutable(.{
        .name = try std.fmt.allocPrint(b.allocator, "{d}-{d}", .{ year, day }),
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addAnonymousImport("utils", utils);

    const unit_test = b.addTest(.{
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
    });
    unit_test.root_module.addAnonymousImport("utils", utils);

    const check_step = b.step("check", "Check for compilation errors");
    check_step.dependOn(&exe.step);

    const run_test = b.addRunArtifact(unit_test);
    const test_step = b.step("test", "Run tests for the day");
    test_step.dependOn(&run_test.step);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the day");
    run_step.dependOn(&run_exe.step);
}
