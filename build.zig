const std = @import("std");
pub fn build(b: *std.Build) void {
    const zig_gobject = b.dependency("gobject-codegen", .{});
    const codegen_exe = zig_gobject.artifact("translate-gir");
    const codegen_exe_run = b.addRunArtifact(codegen_exe);
    const gir_dir = std.process.getEnvVarOwned(b.allocator, "GIR_DIR") catch @panic("OOM");
    const gir_files_path = blk: {
        var result = std.ArrayList([]const u8){};
        if (gir_dir.len > 0) {
            var it = std.mem.splitAny(u8, gir_dir, ":");

            while (it.next()) |dir| {
                result.append(b.allocator, dir) catch @panic("OOM");
            }
        }
        result.append(b.allocator, "./result-dev/share/gir-1.0/") catch @panic("OOM");
        break :blk result.toOwnedSlice(b.allocator) catch @panic("OOM");
    };
    const codegen_modules: []const []const u8 = &.{
        "Gio-2.0",
        "GObject-2.0",
        "GLib-2.0",
        "WPEJavaScriptCore-2.0",
        "WPEPlatform-2.0",
        "WPEPlatformDRM-2.0",
        "WPEPlatformHeadless-2.0",
        "WPEPlatformWayland-2.0",
        "WPEWebKit-2.0",
        "WPEWebProcessExtension-2.0",
    };
    for (gir_files_path) |dir| {
        codegen_exe_run.addPrefixedDirectoryArg("--gir-dir=", .{ .cwd_relative = dir });
    }
    codegen_exe_run.addPrefixedDirectoryArg("--gir-fixes-dir=", zig_gobject.path("gir-fixes"));
    codegen_exe_run.addPrefixedDirectoryArg("--bindings-dir=", zig_gobject.path("binding-overrides"));
    codegen_exe_run.addPrefixedDirectoryArg("--extensions-dir=", zig_gobject.path("extensions"));
    const bindings_dir = codegen_exe_run.addPrefixedOutputDirectoryArg("--output-dir=", "bindings");
    // codegen_exe_run.addPrefixedDirectoryArg("--abi-test-output-dir=", b.path("test/abi"));
    _ = codegen_exe_run.addPrefixedDepFileOutputArg("--dependency-file=", "codegen-deps");
    codegen_exe_run.addArgs(codegen_modules);
    // This is needed to tell Zig that the command run can be cached despite
    // having output files.
    codegen_exe_run.expectExitCode(0);

    const install_bindings = b.addInstallDirectory(.{
        .source_dir = bindings_dir,
        .install_dir = .prefix,
        .install_subdir = "bindings",
    });

    const codegen_step = b.step("codegen", "Generate all bindings");
    codegen_step.dependOn(&install_bindings.step);
}
