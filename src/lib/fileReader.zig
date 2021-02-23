const std = @import("std");
const fs = std.fs;

pub const Error = error{ MissingArgument, TooManyArguments, FileNotFound, FileTooBig } || std.os.ReadError;

pub fn readArgument() Error![:0]u8 {
    var allocator = std.heap.page_allocator;

    var arguments = std.process.args();

    _ = arguments.skip();

    return arguments.next(allocator) orelse Error.MissingArgument catch Error.MissingArgument;
}

pub fn readAsUtf8(path: [:0]u8) Error![]u8 {
    const file = fs.cwd().openFile(path, .{ .read = true }) catch |_| {
        return Error.FileNotFound;
    };
    defer file.close();

    return file.readToEndAlloc(std.heap.page_allocator, 4096) catch Error.FileTooBig;
}

pub fn readFile() Error![]u8 {
    const argument = try readArgument();

    return readAsUtf8(argument);
}
