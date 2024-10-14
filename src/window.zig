const std = @import("std");
const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("fenster.c");
});

pub const Window = struct {
    f: c.fenster,
    w: u32,
    h: u32,
    pub fn init(allocator: Allocator, w: u32, h: u32) !Window {
        var buf = try allocator.alloc(u32, w * h);
        const f = std.mem.zeroInit(c.fenster, .{
            .width = @as(c_int, @intCast(w)), //fmt
            .height = @as(c_int, @intCast(h)),
            .title = "window title",
            .buf = &buf[0],
        });
        return Window{ .f = f, .w = w, .h = h };
    }

    pub fn deinit(self: *Window) void {
        c.fenster_close(&self.f);
    }

    pub fn before_loop(self: *Window) void {
        _ = c.fenster_open(&self.f);
    }

    pub fn loop(self: *Window) bool {
        return c.fenster_loop(&self.f) == 0;
    }

    pub fn set_pixel(self: *Window, x: u32, y: u32, color: u32) void {
        self.f.buf[y * self.w + x] = color;
    }
};
