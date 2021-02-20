const std = @import("std");
const Instruction = @import("tokens.zig").Instruction;

fn join_values(x: u4, y: u4, z: u4) u12 {
    return @as(u12, x) << 8 | @as(u8, y) << 4 | z;
}

pub fn main() void {
    const a: u12 = join_values(0xf, 0xf, 0xf);

    const instruction = Instruction{ .JP = a };

    std.debug.print("{}\n", .{instruction});
}
