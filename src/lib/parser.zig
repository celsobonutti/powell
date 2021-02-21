const std = @import("std");
const ArrayList = std.ArrayList;
const CompilerError = @import("../main.zig").CompilerError;

usingnamespace @import("instructions.zig");
usingnamespace @import("mecha");

fn strEq(first: []const u8, second: []const u8) bool {
    return std.mem.eql(u8, first, second);
}

fn toAddr(v: [3]u4) u12 {
    return @as(u12, v[0]) << 8 | @as(u8, v[1]) << 4 | v[2];
}

const hex = convert(u4, toInt(u4, 16), asStr(ascii.digit(16)));

const whitespace = oneOf(.{
    ascii.char(' '),
    ascii.char('\n'),
});

pub const addr = map(u12, toAddr, manyN(3, hex));

fn toInstructionWithNoArgument(v: []const u8) Instruction {
    if (std.mem.eql(u8, "CLS", v)) {
        return Instruction.ClearDisplay;
    } else if (std.mem.eql(u8, "RET", v)) {
        return Instruction.Return;
    } else {
        unreachable;
    }
}

pub const instruction_with_no_argument = map(Instruction, toInstructionWithNoArgument, oneOf(.{
    asStr(string("CLS")),
    asStr(string("RET")),
}));

fn toInstructionWithAddr(v: anytype) Instruction {
    if (strEq(v[0], "SYS")) {
        return Instruction{ .CallMachineCode = v[1] };
    } else if (strEq(v[0], "JP")) {
        return Instruction{ .GoTo = v[1] };
    } else if (strEq(v[0], "LD I,")) {
        return Instruction{ .SetIAs = v[1] };
    } else if (strEq(v[0], "JP V0,")) {
        return Instruction{ .GoToNPlusV0 = v[1] };
    } else {
        unreachable;
    }
}

pub const instruction_with_addr = map(Instruction, toInstructionWithAddr, combine(.{
    asStr(oneOf(.{
        string("SYS"),
        string("JP V0,"),
        string("JP"),
        string("LD I,"),
    })),
    ascii.char(' '),
    addr,
}));

pub const instruction = oneOf(.{ instruction_with_no_argument, instruction_with_addr });

pub const instructions = combine(.{ instruction, discard(ascii.char('\n')) });

pub fn parse(input: []const u8) CompilerError![]const Instruction {
    var text = input;
    var intructionList = ArrayList(Instruction).init(std.heap.page_allocator);
    var count: u16 = 1;

    while (!std.mem.eql(u8, text, "")) : (count += 1) {
        var result = instructions(text);

        if (result == null) {
            result = instruction(text);

            if (result == null) {
                std.log.err("Parsing error in line {d}", .{count});
                return CompilerError.ParseError;
            }
        }

        text = result.?.rest;
        try intructionList.append(result.?.value);
    }

    return intructionList.items;
}
