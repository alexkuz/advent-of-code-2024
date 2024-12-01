const std = @import("std");

const Reader = std.io.Reader;
const BufferedReader = std.io.BufferedReader;
const File = std.fs.File;
const FileReader = Reader(File, File.ReadError, File.read);
const FileBufferedReader = BufferedReader(4096, FileReader);
const FixedBufferStream = std.io.FixedBufferStream;

pub const AppAllocator = std.heap.c_allocator;

pub const Result = struct { part1: i64, part2: i64, time: u64 };

pub const FileLineReader = struct {
    file: std.fs.File,
    reader: *FileBufferedReader,
    stream: Reader(*FileBufferedReader, FileReader.Error, FileBufferedReader.read),
    allocator: std.mem.Allocator,
    buf: *[1024]u8,

    const Self = @This();

    pub fn open(path: []const u8, allocator: std.mem.Allocator) !FileLineReader {
        var file = try std.fs.cwd().openFile(path, .{});

        var reader = try allocator.create(FileBufferedReader);
        reader.* = std.io.bufferedReader(file.reader());
        const stream = reader.reader();

        const buf = try allocator.create([1024]u8);

        return .{
            .file = file,
            .stream = stream,
            .reader = reader,
            .allocator = allocator,
            .buf = buf,
        };
    }

    pub fn nextUntilDelimiter(self: *Self, delim: u8) !?[]const u8 {
        var fbs = std.io.fixedBufferStream(self.buf);
        self.stream.streamUntilDelimiter(fbs.writer(), delim, 1024) catch |err| switch (err) {
            error.EndOfStream => if (fbs.getWritten().len == 0) {
                return null;
            },
            else => |e| return e,
        };

        const line = if (delim == '\n') fbs.getWritten() else std.mem.trim(u8, fbs.getWritten(), "\n");
        return line;
    }

    pub fn next(self: *Self) !?[]const u8 {
        return self.nextUntilDelimiter('\n');
    }

    pub fn close(self: *Self) void {
        self.file.close();
        self.allocator.destroy(self.reader);
        self.allocator.destroy(self.buf);
    }
};

const Part = enum(u2) { Part1, Part2 };

pub fn testResult(comptime filename: []const u8, dayFn: anytype, part: Part, expected: i64) !void {
    const allocator = std.testing.allocator;
    var reader = try FileLineReader.open("../test-data/" ++ filename, allocator);
    defer reader.close();

    const result = try dayFn(allocator, &reader);

    switch (part) {
        .Part1 => try std.testing.expectEqual(expected, result.part1),
        .Part2 => try std.testing.expectEqual(expected, result.part2),
    }
}
