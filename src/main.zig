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

    const cube_tris = try stl.load_stl(allocator, "cube.stl", 0xff0000);
    defer allocator.free(cube_tris);

    var cube_mesh = storage.Mesh.init(0, 12);
    cube_mesh.transform.position = storage.V3{ .x = 400, .y = 500, .z = 0 };
    cube_mesh.transform.scale = storage.V3{ .x = 200, .y = 200, .z = 200 };

    var cube_mesh2 = storage.Mesh.init(0, 12);
    cube_mesh2.transform.position = storage.V3{ .x = 800, .y = 500, .z = 0 };
    cube_mesh2.transform.scale = storage.V3{ .x = 300, .y = 300, .z = 300 };
    cube_mesh2.transform.rotation = storage.V3{ .x = 1, .y = 0.5, .z = -0.1 };
    tribuf.insert(cube_mesh, cube_tris);
    meshbuf.insert(cube_mesh);
    meshbuf.insert(cube_mesh2);

    const text_tris = try text.mesh_from_text(allocator, "text", 0x102ff0, 20);
    var text_mesh = storage.Mesh.init(tribuf.size, tribuf.size + text_tris.len);
    text_mesh.transform.position = storage.V3{ .x = 200, .y = 900, .z = 0 };
    tribuf.insert(text_mesh, text_tris);
    meshbuf.insert(text_mesh);

    const bunny_tris = try stl.load_stl(allocator, "bunny.stl", 0x0ff00);
    defer allocator.free(bunny_tris);
    var bunny_mesh = storage.Mesh.init(tribuf.size, tribuf.size + bunny_tris.len);
    bunny_mesh.transform.position = storage.V3{ .x = 300, .y = 200, .z = 0 };
    bunny_mesh.transform.scale = storage.V3{ .x = 4, .y = 4, .z = 4 };
    tribuf.insert(bunny_mesh, bunny_tris);
    meshbuf.insert(bunny_mesh);

    const torus_tris = try stl.load_stl(allocator, "torus.stl", 0x0000ff);
    defer allocator.free(torus_tris);
    var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
    torus_mesh.transform.position = storage.V3{ .x = 800, .y = 800, .z = 0 };
    torus_mesh.transform.scale = storage.V3{ .x = 100, .y = 100, .z = 100 };
    tribuf.insert(torus_mesh, torus_tris);
    meshbuf.insert(torus_mesh);

    var window = try Window.init(allocator, 1024, 1024);
    defer window.deinit();

    window.before_loop();
    while (window.loop()) {
        window.set_pixel(50, 100, 0xff0000);
        draw.clear(&window, 0xf0a0bb);
        meshbuf.buffer[3].transform.rotation.x += 0.005;
        meshbuf.buffer[3].transform.rotation.y += 0.005;
        meshbuf.buffer[3].transform.rotation.z += 0.005;

        meshbuf.buffer[0].transform.rotation.x += 0.005;
        meshbuf.buffer[0].transform.rotation.y -= 0.01;
        meshbuf.buffer[0].transform.rotation.z += 0.005;

        // meshbuf.buffer[2].transform.rotation.x += 0.005;
        meshbuf.buffer[2].transform.rotation.y += 0.005;
        // meshbuf.buffer[2].transform.rotation.z += 0.005;

        meshbuf.buffer[4].transform.rotation.y += 0.05;
        meshbuf.buffer[4].transform.rotation.x += 0.05;

        draw.draw_orthographic(&window, tribuf, meshbuf);
    }
}
