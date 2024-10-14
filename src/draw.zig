const std = @import("std");
const storage = @import("storage.zig");
const Window = @import("window.zig").Window;

pub fn draw_orthographic(window: *Window, tribuf: storage.TriangleBuffer, meshbuf: storage.MeshBuffer) void {
    for (0..meshbuf.size) |i| {
        const mesh = meshbuf.buffer[i];
        const triangles = tribuf.buffer[mesh.start..mesh.end];
        for (0..triangles.len) |j| {
            draw_triangle(window, triangles[j]);
        }
    }
}

fn draw_triangle(window: *Window, tri: storage.Triangle) void {
    draw_line(window, @intFromFloat(tri.p0.x), @intFromFloat(tri.p0.y), @intFromFloat(tri.p1.x), @intFromFloat(tri.p1.y), tri.color);
    draw_line(window, @intFromFloat(tri.p1.x), @intFromFloat(tri.p1.y), @intFromFloat(tri.p2.x), @intFromFloat(tri.p2.y), tri.color);
    draw_line(window, @intFromFloat(tri.p2.x), @intFromFloat(tri.p2.y), @intFromFloat(tri.p0.x), @intFromFloat(tri.p0.y), tri.color);
}

fn draw_line(window: *Window, x0: i32, y0: i32, x1: i32, y1: i32, color: u32) void {
    var x = x0;
    var y = y0;
    const dx: i32 = @intCast(@abs(x1 - x0));
    const sx: i32 = if (x0 < x1) 1 else -1;
    var dy: i32 = @intCast(@abs(y1 - y0));
    dy *= -1;

    const sy: i32 = if (y0 < y1) 1 else -1;

    var err = dx + dy;

    while (true) {
        if ((x < window.w) and (x > 0) and (y < window.h) and (y > 0)) {
            window.set_pixel(@intCast(x), @intCast(y), color);
        }
        if ((x == x1) and (y == y1)) break;
        const err2 = 2 * err;

        if (err2 >= dy) {
            err += dy;
            x += sx;
        }
        if (err2 <= dx) {
            err += dx;
            y += sy;
        }
    }
}
