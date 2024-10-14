const std = @import("std");
const Window = @import("window.zig").Window;
const storage = @import("storage.zig");
const stl = @import("stl.zig");
const draw = @import("draw.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    const tris = try allocator.alloc(storage.Triangle, 1_000_000);
    defer allocator.free(tris);
    var tribuf = storage.TriangleBuffer.init(tris);

    const meshes = try allocator.alloc(storage.Mesh, 10);
    var meshbuf = storage.MeshBuffer.init(meshes);

    const cube_tris = try stl.load_stl(allocator, "cube.stl");
    defer allocator.free(cube_tris);

    const cube_mesh = storage.Mesh.init(0, 12);
    tribuf.insert(cube_mesh, cube_tris);
    meshbuf.insert(cube_mesh);

    var window = try Window.init(allocator, 1024, 1024);
    defer window.deinit();

    window.before_loop();
    while (window.loop()) {
        window.set_pixel(50, 100, 0xff0000);
        draw.draw_orthographic(&window, tribuf, meshbuf);
    }
}
