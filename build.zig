const Builder = @import("std").build.Builder;
const pkgs = @import("gyro").pkgs;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("main", "src/main.zig");
    pkgs.addAllTo(exe);
    exe.install();
}
