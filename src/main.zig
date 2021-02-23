const std = @import("std");
const Instruction = @import("lib/instructions.zig").Instruction;
const parser = @import("lib/parser.zig");
const fileReader = @import("lib/fileReader.zig");

const CompilerError = parser.Error || fileReader.Error;

pub fn main() void {
    var file = fileReader.readFile() catch |err| {
        return;
    };

    var instructions = parser.parse(file) catch |err| {
        return;
    };

    std.debug.print("{s}\n", .{instructions.items});

    instructions.deinit();
}
