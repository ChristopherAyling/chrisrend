const std = @import("std");
const storage = @import("storage.zig");
const Window = @import("window.zig").Window;

pub fn clear(window: *Window, color: u32) void {
    for (0..window.w * window.h) |i| {
        window.f.buf[i] = color;
    }
}

pub fn draw_orthographic(window: *Window, tribuf: storage.TriangleBuffer, meshbuf: storage.MeshBuffer) void {
    for (0..meshbuf.size) |i| {
        const mesh = meshbuf.buffer[i];
        const triangles = tribuf.buffer[mesh.start..mesh.end];
        draw_mesh(window, mesh, triangles);
    }
}

fn draw_mesh(window: *Window, mesh: storage.Mesh, triangles: []storage.Triangle) void {
    for (0..triangles.len) |i| {
        const triangle = triangles[i];
        var triangle_render = triangle;
        std.log.debug("before", .{});
        triangle_render.p0.print();
        transform_triangle(&triangle_render, mesh.transform);
        std.log.debug("after", .{});
        triangle_render.p1.print();
        draw_triangle(window, triangle_render);
    }
}

fn transform_triangle(triangle: *storage.Triangle, transform: storage.Transform) void {
    scale_triangle(triangle, transform.scale);
    translate_triangle(triangle, transform.position);
    rotate_triangle(triangle, transform.rotation);
}

fn translate_triangle(triangle: *storage.Triangle, t: storage.V3) void {
    const tx = t.x;
    const ty = t.y;
    const tz = t.z;

    const p0 = &triangle.p0;
    const p1 = &triangle.p1;
    const p2 = &triangle.p2;

    p0.x += tx;
    p0.y += ty;
    p0.z += tz;

    p1.x += tx;
    p1.y += ty;
    p1.z += tz;

    p2.x += tx;
    p2.y += ty;
    p2.z += tz;
}

fn rotate_triangle(triangle: *storage.Triangle, r: storage.V3) void {
    const rx = r.x;
    const ry = r.y;
    const rz = r.z;

    rotate_x(triangle, rx);
    rotate_y(triangle, ry);
    rotate_z(triangle, rz);
}

fn scale_triangle(triangle: *storage.Triangle, s: storage.V3) void {
    const sx = s.x;
    const sy = s.y;
    const sz = s.z;

    const p0 = &triangle.p0;
    const p1 = &triangle.p1;
    const p2 = &triangle.p2;

    p0.x *= sx;
    p0.y *= sy;
    p0.z *= sz;

    p1.x *= sx;
    p1.y *= sy;
    p1.z *= sz;

    p2.x *= sx;
    p2.y *= sy;
    p2.z *= sz;
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

pub fn rotate_x(triangle: *storage.Triangle, theta: f32) void {
    const sin_theta = @sin(theta);
    const cos_theta = @cos(theta);
    const p0 = &triangle.p0;
    const p1 = &triangle.p1;
    const p2 = &triangle.p2;

    const y0 = p0.y;
    const z0 = p0.z;
    p0.y = y0 * cos_theta - z0 * sin_theta;
    p0.z = z0 * cos_theta + y0 * sin_theta;

    const y1 = p1.y;
    const z1 = p1.z;
    p1.y = y1 * cos_theta - z1 * sin_theta;
    p1.z = z1 * cos_theta + y1 * sin_theta;

    const y2 = p2.y;
    const z2 = p2.z;
    p2.y = y2 * cos_theta - z2 * sin_theta;
    p2.z = z2 * cos_theta + y2 * sin_theta;
}

pub fn rotate_z(triangle: *storage.Triangle, theta: f32) void {
    const sin_theta = @sin(theta);
    const cos_theta = @cos(theta);
    const p0 = &triangle.p0;
    const p1 = &triangle.p1;
    const p2 = &triangle.p2;

    const x0 = p0.x;
    const y0 = p0.y;
    p0.x = x0 * cos_theta - y0 * sin_theta;
    p0.y = y0 * cos_theta + x0 * sin_theta;

    const x1 = p1.x;
    const y1 = p1.y;
    p1.x = x1 * cos_theta - y1 * sin_theta;
    p1.y = y1 * cos_theta + x1 * sin_theta;

    const x2 = p2.x;
    const y2 = p2.y;
    p2.x = x2 * cos_theta - y2 * sin_theta;
    p2.y = y2 * cos_theta + x2 * sin_theta;
}

pub fn rotate_y(triangle: *storage.Triangle, theta: f32) void {
    const sin_theta = @sin(theta);
    const cos_theta = @cos(theta);
    const p0 = &triangle.p0;
    const p1 = &triangle.p1;
    const p2 = &triangle.p2;

    const x0 = p0.x;
    const z0 = p0.z;
    p0.x = x0 * cos_theta + z0 * sin_theta;
    p0.z = z0 * cos_theta - x0 * sin_theta;

    const x1 = p1.x;
    const z1 = p1.z;
    p1.x = x1 * cos_theta + z1 * sin_theta;
    p1.z = z1 * cos_theta - x1 * sin_theta;

    const x2 = p2.x;
    const z2 = p2.z;
    p2.x = x2 * cos_theta + z2 * sin_theta;
    p2.z = z2 * cos_theta - x2 * sin_theta;
}
