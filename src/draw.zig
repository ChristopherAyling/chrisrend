const std = @import("std");
const storage = @import("storage.zig");
const Window = @import("window.zig").Window;

pub fn clear(window: *Window, color: u32) void {
    for (0..window.w * window.h) |i| {
        window.f.buf[i] = color;
    }
}

pub fn draw_orthographic(window: *Window, tribuf: *storage.TriangleBuffer, meshbuf: storage.MeshBuffer) void {
    for (0..meshbuf.size) |i| {
        const mesh = meshbuf.buffer[i];
        const triangles = tribuf.buffer[mesh.start..mesh.end];
        draw_mesh(window, mesh, triangles);
    }
}

pub fn triangle_compare(thing: void, a: storage.Triangle, b: storage.Triangle) bool {
    _ = thing;
    // return a.p0.z > b.p0.z;
    return (a.p0.z + a.p1.z + a.p2.z) / 3 > (b.p0.z + b.p1.z + b.p2.z) / 3;
    // return a.p0.z > b.p0.z and a.p1.z > b.p1.z and a.p2.z > b.p2.z;
}

fn color_v3_to_rgb(color_v3: storage.V3) u32 {
    const r: u32 = @intFromFloat(color_v3.x * 255);
    const g: u32 = @intFromFloat(color_v3.y * 255);
    const b: u32 = @intFromFloat(color_v3.z * 255);
    return (r << 16) | (g << 8) | b;
}

pub fn apply_lighting(color_u32: u32, normal: storage.V3) u32 {
    // blinn phong reflection model
    const V3 = storage.V3;
    const red: u8 = @intCast((color_u32 >> 16) & 0xFF);
    const green: u8 = @intCast((color_u32 >> 8) & 0xFF);
    const blue: u8 = @intCast(color_u32 & 0xFF);

    const model_color_255 = V3{
        .x = @floatFromInt(red),
        .y = @floatFromInt(green),
        .z = @floatFromInt(blue),
    };
    const model_color = model_color_255.div(V3.somes(255));

    const light_color = V3.init(0.5, 0.5, 0.5);
    const light_source = V3.init(0.5, 0, 0);

    const ambient = V3.somes(0.5);

    const diffuse_strength = @max(0, normal.dot(light_source));
    const diffuse = V3.somes(diffuse_strength).mul(light_color);

    const camera_source = V3.init(0, 0, -1);
    const view_source = camera_source.normalize();
    const reflect_source = light_source.neg().reflect(normal);
    const specular_strength = @max(0, view_source.dot(reflect_source));
    const specular = light_color.mul(V3.somes(specular_strength));
    // const specular = V3.somes(0);

    // _ = ambient;
    // _ = diffuse;
    // const lighting = specular;
    const lighting = ambient.add(diffuse).add(specular);

    const color = model_color.mul(lighting);
    const rgbu32 = color_v3_to_rgb(color);
    return rgbu32;
}

fn draw_mesh(window: *Window, mesh: storage.Mesh, triangles: []storage.Triangle) void {
    // transform
    for (0..triangles.len) |i| {
        transform_triangle(window, &triangles[i], mesh.transform);
    }

    // sort
    std.mem.sort(storage.Triangle, triangles, {}, triangle_compare);

    // draw
    for (0..triangles.len) |i| {
        var triangle = triangles[i];
        // triangle.color = normal_to_rgb(triangle.normal);
        // triangle.color = 0x00ff00;
        triangle.color = apply_lighting(triangle.color, triangle.calc_normal());
        fill_triangle(window, triangle);
        triangle.color = 0xffffff;
        draw_triangle(window, triangle);
    }
}

fn transform_triangle(window: *Window, triangle: *storage.Triangle, transform: storage.Transform) void {
    scale_triangle(triangle, transform.scale);
    rotate_triangle(triangle, transform.rotation);
    translate_triangle(triangle, transform.position);
    const perspective = storage.Mat4x4.perspective(55, @floatFromInt(window.h / window.w), 0.01, 1000);
    perspective_triangle(triangle, perspective);
}

fn perspective_triangle(triangle: *storage.Triangle, perspective: storage.Mat4x4) void {
    const p0 = triangle.p0;
    const p1 = triangle.p1;
    const p2 = triangle.p2;

    const p0_4 = storage.mul_mat_vec(perspective, p0);
    const p1_4 = storage.mul_mat_vec(perspective, p1);
    const p2_4 = storage.mul_mat_vec(perspective, p2);

    triangle.p0 = p0_4;
    triangle.p1 = p1_4;
    triangle.p2 = p2_4;
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

pub fn fill_triangle_flat_top(window: *Window, tri: storage.Triangle) void {
    const invslope1 = (tri.p2.x - tri.p1.x) / (tri.p2.y - tri.p1.y); // slope between p2 and p1
    const invslope2 = (tri.p2.x - tri.p0.x) / (tri.p2.y - tri.p0.y); // slope between p2 and p0

    var curx1 = tri.p2.x;
    var curx2 = tri.p2.x;

    var y = tri.p2.y;
    while (y >= tri.p1.y) {
        draw_line(window, @intFromFloat(curx1), @intFromFloat(y), @intFromFloat(curx2), @intFromFloat(y), tri.color);
        curx1 -= invslope1;
        curx2 -= invslope2;
        y -= 1;
    }
}

fn fill_triangle_flat_bottom(window: *Window, tri: storage.Triangle) void {
    const invslope1 = (tri.p2.x - tri.p1.x) / (tri.p2.y - tri.p1.y); // slope between p2 and p1
    const invslope2 = (tri.p2.x - tri.p0.x) / (tri.p2.y - tri.p0.y); // slope between p2 and p0

    var curx1 = tri.p2.x;
    var curx2 = tri.p2.x;

    var y = tri.p2.y;
    while (y <= (tri.p0.y)) {
        draw_line(window, @intFromFloat(curx1), @intFromFloat(y), @intFromFloat(curx2), @intFromFloat(y), tri.color);
        curx1 += invslope1;
        curx2 += invslope2;
        y += 1;
    }
}

fn triangle_y_compare(context: void, a: storage.V3, b: storage.V3) bool {
    _ = context;
    return a.y < b.y;
}

fn sort_triangle_y(tri: storage.Triangle) storage.Triangle {
    var sorted = [3]storage.V3{ tri.p0, tri.p1, tri.p2 };
    std.mem.sort(storage.V3, &sorted, {}, triangle_y_compare);
    return storage.Triangle{ .p0 = sorted[0], .p1 = sorted[1], .p2 = sorted[2], .color = tri.color, .normal = tri.normal };
}

pub fn fill_triangle(window: *Window, tri: storage.Triangle) void {
    const tri_sorted = sort_triangle_y(tri);
    const bot = tri_sorted.p2;
    const mid = tri_sorted.p1;
    const top = tri_sorted.p0;
    const slope = (bot.x - top.x) / (bot.y - top.y);
    const t = storage.V3{
        .x = top.x + slope * (mid.y - top.y), // Correct interpolation based on slope
        .y = mid.y, // Same y as mid
        .z = undefined,
    };

    const flat_bottom = storage.Triangle{
        .p0 = mid, //.
        .p1 = t,
        .p2 = top,
        .color = tri.color,
        .normal = tri.normal,
    };
    const flat_top = storage.Triangle{
        .p0 = t, //.
        .p1 = mid,
        .p2 = bot,
        .color = tri.color,
        .normal = tri.normal,
    };
    fill_triangle_flat_bottom(window, flat_bottom);
    fill_triangle_flat_top(window, flat_top);
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

fn clamp(n: f32, min: f32, max: f32) f32 {
    if (n < min) return min;
    if (n > max) return max;
    return n;
}

fn normal_to_rgb(normal: storage.V3) u32 {
    var nx = normal.x;
    var ny = normal.y;
    var nz = normal.z;

    nx = (nx + 1) * 0.5;
    ny = (ny + 1) * 0.5;
    nz = (nz + 1) * 0.5;

    nx = clamp(nx, 0.0, 1.0);
    ny = clamp(ny, 0.0, 1.0);
    nz = clamp(nz, 0.0, 1.0);

    const r: u32 = @intFromFloat(nx * 255);
    const g: u32 = @intFromFloat(ny * 255);
    const b: u32 = @intFromFloat(nz * 255);

    const color: u32 = (r << 16) | (g << 8) | b;
    return color;
}
