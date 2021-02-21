const Register = u4;

const RegisterValuePair = struct {
    register: u4, value: u8
};

const TargetSourcePair = struct {
    target: u4, source: u4
};

pub const Instruction = union(enum) {
    CallMachineCode: u12,
    ClearDisplay,
    Return,
    GoTo: u12,
    Call: u12,
    SkipIfEqual: RegisterValuePair,
    SkipIfDifferent: RegisterValuePair,
    SkipIfRegisterEqual: TargetSourcePair,
    AssignValueToRegister: RegisterValuePair,
    AddValueToRegister: RegisterValuePair,
    AssignVYToVX: TargetSourcePair,
    SetXOrY: TargetSourcePair,
    SetXAndY: TargetSourcePair,
    SetXXorY: TargetSourcePair,
    AddYToX: TargetSourcePair,
    SubYFromX: TargetSourcePair,
    ShiftRight: Register,
    SetXAsYMinusX: TargetSourcePair,
    ShiftLeft: Register,
    SkipIfRegisterDifferent: TargetSourcePair,
    SetIAs: u12,
    GoToNPlusV0: u12,
    Random: RegisterValuePair,
    Draw: struct { x: Register, y: Register, height: u4 },
    SkipIfKeyPressed: u4,
    SkipIfKeyNotPressed: u4,
    SetXAsDelay: Register,
    WaitForInputAndStoreIn: Register,
    SetDelayAsX: Register,
    SetSoundAsX: Register,
    AddXToI: Register,
    SetIAsFontSprite: Register,
    StoreBCD: Register,
    DumpRegisters: Register,
    LoadRegisters: Register,
};
