const std = @import("std");
const Allocator = std.mem.Allocator;
const storage = @import("storage.zig");

const V3 = storage.V3;

const font5x3 = [_]u16{ 0x0000, 0x2092, 0x002d, 0x5f7d, 0x279e, 0x52a5, 0x7ad6, 0x0012, 0x4494, 0x1491, 0x017a, 0x05d0, 0x1400, 0x01c0, 0x0400, 0x12a4, 0x2b6a, 0x749a, 0x752a, 0x38a3, 0x4f4a, 0x38cf, 0x3bce, 0x12a7, 0x3aae, 0x49ae, 0x0410, 0x1410, 0x4454, 0x0e38, 0x1511, 0x10e3, 0x73ee, 0x5f7a, 0x3beb, 0x624e, 0x3b6b, 0x73cf, 0x13cf, 0x6b4e, 0x5bed, 0x7497, 0x2b27, 0x5add, 0x7249, 0x5b7d, 0x5b6b, 0x3b6e, 0x12eb, 0x4f6b, 0x5aeb, 0x388e, 0x2497, 0x6b6d, 0x256d, 0x5f6d, 0x5aad, 0x24ad, 0x72a7, 0x6496, 0x4889, 0x3493, 0x002a, 0xf000, 0x0011, 0x6b98, 0x3b79, 0x7270, 0x7b74, 0x6750, 0x95d6, 0xb9ee, 0x5b59, 0x6410, 0xb482, 0x56e8, 0x6492, 0x5be8, 0x5b58, 0x3b70, 0x976a, 0xcd6a, 0x1370, 0x38f0, 0x64ba, 0x3b68, 0x2568, 0x5f68, 0x54a8, 0xb9ad, 0x73b8, 0x64d6, 0x2492, 0x3593, 0x03e0 };

pub fn mesh_from_rect(x: f32, y: f32, w: f32, h: f32, color: u32) [2]storage.Triangle {
    const tri_top_left = storage.Triangle{ .p0 = V3{ .x = x, .y = y, .z = 0 }, .p1 = V3{ .x = x + w, .y = y, .z = 0 }, .p2 = V3{ .x = x + w, .y = y + h, .z = 0 }, .color = color, .normal = undefined };
    const tri_bottom_right = storage.Triangle{ .p0 = V3{ .x = x + w, .y = y + h, .z = 0 }, .p1 = V3{ .x = x, .y = y + h, .z = 0 }, .p2 = V3{ .x = x, .y = y, .z = 0 }, .color = color, .normal = undefined };
    return [_]storage.Triangle{ tri_top_left, tri_bottom_right };
}

pub fn mesh_from_text(allocator: Allocator, text: []const u8, color: u32, scale: u32) ![]storage.Triangle {
    // allocate maximum possible size (15*2*#chars)

    var triangles = try allocator.alloc(storage.Triangle, 15 * 2 * text.len);

    const x = 0;
    const y = 0;
    var xc: u32 = x;
    var tricounter: u32 = 0;
    for (0..text.len) |i| {
        const chr = text[i];
        if (chr > 32) {
            const bmp: u16 = font5x3[chr - 32];
            for (0..5) |dy| {
                for (0..3) |dx| {
                    const shift_value: u4 = @as(u4, @intCast(dy)) * 3 + @as(u4, @intCast(dx));
                    const not_blank = bmp >> shift_value & 1;
                    if (not_blank != 0) {
                        const rx: f32 = @floatFromInt(xc + dx * scale);
                        const ry: f32 = @floatFromInt(y + dy * scale);
                        const sc: f32 = @floatFromInt(scale);
                        const rect_triangles = mesh_from_rect(rx, ry, sc, sc, color);
                        triangles[tricounter] = rect_triangles[0];
                        triangles[tricounter + 1] = rect_triangles[1];
                        tricounter += 2;
                    }
                }
            }
        }
        xc = xc + 4 * scale;
    }
    return triangles[0..tricounter];
}
