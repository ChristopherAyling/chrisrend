const std = @import("std");
const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("fenster.c");
});

pub const Window = struct {
    f: c.fenster,
    triangle_id_buffer: []u32,
    w: u32,
    h: u32,
    debug: bool = true,
    fps: u32 = 60,
    pub fn init(allocator: Allocator, w: u32, h: u32) !Window {
        var buf = try allocator.alloc(u32, w * h);
        const triangle_id_buffer = try allocator.alloc(u32, w * h);
        const f = std.mem.zeroInit(c.fenster, .{
            .width = @as(c_int, @intCast(w)), //fmt
            .height = @as(c_int, @intCast(h)),
            .title = "window title",
            .buf = &buf[0],
        });
        return Window{ .f = f, .w = w, .h = h, .triangle_id_buffer = triangle_id_buffer };
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
        if (x >= self.w or y >= self.h) return;
        self.f.buf[y * self.w + x] = color;
    }

    pub fn set_triangle_id(self: *Window, x: u32, y: u32, triangle_id: u32) void {
        if (x >= self.w or y >= self.h) return;
        self.triangle_id_buffer[y * self.w + x] = triangle_id;
    }

    pub fn get_triangle_id(self: *Window, x: u32, y: u32) u32 {
        return self.triangle_id_buffer[y * self.w + x];
    }

    pub fn key(self: Window, k: usize) bool {
        return self.f.keys[k] != 0;
    }
};
