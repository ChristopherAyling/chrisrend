const std = @import("std");
const Allocator = std.mem.Allocator;
const storage = @import("storage.zig");

fn u32_from_bytes(b: *[4]u8) u32 {
    return std.mem.readInt(u32, b, .little);
}

fn f32_from_bytes(b: *[4]u8) f32 {
    return @bitCast(b.*);
}

fn v3_from_stl_bytes(bytes: []u8) storage.V3 {
    const scale = 300;
    return storage.V3{
        .x = f32_from_bytes(bytes[0..4]) * scale, //fmt
        .y = f32_from_bytes(bytes[4..8]) * scale,
        .z = f32_from_bytes(bytes[8..12]) * scale,
    };
}

fn triangle_from_stl_bytes(bytes: []u8) storage.Triangle {
    return storage.Triangle{ .normal = v3_from_stl_bytes(bytes[0..12]), .p0 = v3_from_stl_bytes(bytes[12..24]), .p1 = v3_from_stl_bytes(bytes[24..36]), .p2 = v3_from_stl_bytes(bytes[36..48]), .color = 0xff0000 };
}

pub fn load_stl(allocator: Allocator, path: []const u8) ![]storage.Triangle {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const reader = file.reader();
    var buf: [4000960]u8 = undefined;
    const size = try reader.readAll(&buf);
    const data = buf[0..size];
    const n_triangles = u32_from_bytes(buf[80..84]);
    var tridx: usize = 84;

    var triangles = try allocator.alloc(storage.Triangle, n_triangles);
    for (0..triangles.len) |i| {
        triangles[i] = triangle_from_stl_bytes(data[tridx .. tridx + 48]);
        tridx += 50;
    }
    return triangles;
}
