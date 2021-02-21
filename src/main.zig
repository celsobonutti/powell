const std = @import("std");
const Instruction = @import("lib/instructions.zig").Instruction;
const parser = @import("lib/parser.zig");

pub const CompilerError = error{ ParseError, OutOfMemory };

pub fn main() void {
    var input: []const u8 = "JP V0, AAA\nJP 000";
    var instructions = parser.parse(input);
}
