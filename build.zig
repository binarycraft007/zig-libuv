const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Add standard target options
    const target = b.standardTargetOptions(.{});
    // Add standard optimize options
    const optimize = b.standardOptimizeOption(.{});
    // Add the module
    const uv_module = b.addModule(
        "uv",
        .{
            .source_file = .{ .path = "src/uv.zig" },
        },
    );
    // Add the unit tests
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/uv.zig" },
        .target = target,
        .optimize = optimize,
    });
    const unit_tests_step = b.step("test", "Run unit tests");
    unit_tests_step.dependOn(&unit_tests.step);
    unit_tests.test_evented_io = true;

    // Add examples
    const examples = [_][]const u8{
        //"examples/cgi/cgi.zig",
        "examples/detach.zig",
        "examples/dns.zig",
        "examples/locks.zig",
        "examples/onchange.zig",
        "examples/proc_streams.zig",
        "examples/progress.zig",
        "examples/queue_work.zig",
        "examples/signal.zig",
        "examples/spawn.zig",
        "examples/thread_create.zig",
        "examples/timer.zig",
        "examples/uvcat.zig",
        "examples/uvstop.zig",
        "examples/uvtee.zig",
    };

    // For each example
    inline for (examples) |example| {
        const name = example["examples/".len .. example.len - 4];
        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = .{ .path = example },
            .target = target,
            .optimize = optimize,
        });
        exe.addModule("uv", uv_module);

        exe.linkSystemLibrary("uv");
        exe.linkLibC();
        exe.install();
        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run" ++ name);
        run_step.dependOn(&run_cmd.step);
    }
}
