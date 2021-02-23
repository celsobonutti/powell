const std = @import("std");
const ArrayList = std.ArrayList;

pub const Error = error{ ParseError, OutOfMemory };

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

fn toInstructionEndingWithRegister(v: anytype) Instruction {
    if (strEq(v[0], "SKP V")) {
        return Instruction{ .SkipIfKeyPressed = v[1] };
    } else if (strEq(v[0], "SKNP V")) {
        return Instruction{ .SkipIfKeyNotPressed = v[1] };
    } else if (strEq(v[0], "LD DT, V")) {
        return Instruction{ .SetDelayAsX = v[1] };
    } else if (strEq(v[0], "LD ST, V")) {
        return Instruction{ .SetSoundAsX = v[1] };
    } else if (strEq(v[0], "ADD I, V")) {
        return Instruction{ .AddXToI = v[1] };
    } else if (strEq(v[0], "LD F, V")) {
        return Instruction{ .SetIAsFontSprite = v[1] };
    } else if (strEq(v[0], "LD B, V")) {
        return Instruction{ .StoreBCD = v[1] };
    } else if (strEq(v[0], "LD [I], V")) {
        return Instruction{ .DumpRegisters = v[1] };
    } else if (strEq(v[0], "SHR V")) {
        return Instruction{ .ShiftRight = v[1] };
    } else if (strEq(v[0], "SHL V")) {
        return Instruction{ .ShiftLeft = v[1] };
    } else {
        unreachable;
    }
}

const instruction_ending_with_register = map(Instruction, toInstructionEndingWithRegister, combine(.{
    asStr(oneOf(.{
        string("SKP V"),
        string("SKNP V"),
        string("LD DT, V"),
        string("LD ST, V"),
        string("ADD I, V"),
        string("LD F, V"),
        string("LD B, V"),
        string("LD [I], V"),
        string("SHR V"),
        string("SHL V"),
    })),
    hex,
}));

fn toInstructionStartingWithRegister(v: anytype) Instruction {
    if (strEq(v[1], ", DT")) {
        return Instruction{ .SetXAsDelay = v[0] };
    } else if (strEq(v[1], ", K")) {
        return Instruction{ .WaitForInputAndStoreIn = v[0] };
    } else if (strEq(v[1], ", [I]")) {
        return Instruction{ .LoadRegisters = v[0] };
    } else {
        unreachable;
    }
}

const instruction_starting_with_register = map(Instruction, toInstructionStartingWithRegister, combine(.{
    string("LD V"),
    hex,
    asStr(oneOf(.{
        string(", DT"),
        string(", K"),
        string(", [I]"),
    })),
}));

pub const instruction = oneOf(.{
    instruction_with_no_argument,
    instruction_with_addr,
    instruction_starting_with_register,
    instruction_ending_with_register,
});

pub const instructionWithLineBreak = combine(.{ instruction, discard(ascii.char('\n')) });

pub fn parse(input: []const u8) Error!ArrayList(Instruction) {
    var text = input;
    var instructionList = ArrayList(Instruction).init(std.heap.page_allocator);
    var count: u16 = 1;

    while (!std.mem.eql(u8, text, "")) : (count += 1) {
        var result = instructionWithLineBreak(text);

        if (result == null) {
            result = instruction(text);

            if (result == null) {
                std.log.err("Parsing error on line {d}", .{count});
                return Error.ParseError;
            }
        }

        text = result.?.rest;
        try instructionList.append(result.?.value);
    }

    return instructionList;
}
