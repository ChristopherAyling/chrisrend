const std = @import("std");
const Window = @import("window.zig").Window;
const storage = @import("storage.zig");
const stl = @import("stl.zig");
const draw = @import("draw.zig");
const text = @import("text.zig");

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

    var cube_mesh = storage.Mesh.init(0, 12);
    cube_mesh.transform.position = storage.V3{ .x = 500, .y = 500, .z = 0 };
    cube_mesh.transform.scale = storage.V3{ .x = 300, .y = 300, .z = 300 };
    // cube_mesh.transform.rotation = storage.V3.ones();

    var cube_mesh2 = storage.Mesh.init(0, 12);
    cube_mesh2.transform.position = storage.V3{ .x = 500, .y = 500, .z = 0 };
    cube_mesh2.transform.scale = storage.V3{ .x = 300, .y = 300, .z = 300 };
    cube_mesh2.transform.rotation = storage.V3{ .x = 1, .y = 0.5, .z = -0.1 };

    tribuf.insert(cube_mesh, cube_tris);
    meshbuf.insert(cube_mesh);
    meshbuf.insert(cube_mesh2);

    const text_tris = try text.mesh_from_text(allocator, "ILY", 0x102ff0, 20);
    var text_mesh = storage.Mesh.init(tribuf.size, tribuf.size + text_tris.len);
    text_mesh.transform.position = storage.V3{ .x = 500, .y = 500, .z = 0 };

    tribuf.insert(text_mesh, text_tris);
    meshbuf.insert(text_mesh);

    var window = try Window.init(allocator, 1024, 1024);
    defer window.deinit();

    window.before_loop();
    while (window.loop()) {
        window.set_pixel(50, 100, 0xff0000);
        draw.clear(&window, 0xf0a0bb);
        meshbuf.buffer[2].transform.rotation.y += 0.001;
        // meshbuf.buffer[2].transform.rotation.z += 0.005;
        meshbuf.buffer[2].transform.position.x = @floatFromInt(window.f.x);
        meshbuf.buffer[2].transform.position.y = @floatFromInt(window.f.y);
        draw.draw_orthographic(&window, tribuf, meshbuf);
    }
}
