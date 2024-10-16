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

    const render_tris = try allocator.alloc(storage.Triangle, 1_000_000);
    defer allocator.free(render_tris);
    var render_tribuf = storage.TriangleBuffer.init(render_tris);

    const meshes = try allocator.alloc(storage.Mesh, 10);
    var meshbuf = storage.MeshBuffer.init(meshes);

    {
        const torus_tris = try stl.load_stl(allocator, "torus.stl", 0x0000ff);
        defer allocator.free(torus_tris);
        var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
        torus_mesh.transform.position = storage.V3{ .x = 200, .y = 200, .z = -100 };
        torus_mesh.transform.scale = storage.V3{ .x = 300, .y = 300, .z = 300 };
        tribuf.insert(torus_mesh, torus_tris);
        meshbuf.insert(torus_mesh);
    }

    // {
    //     const torus_tris = try stl.load_stl(allocator, "bunny.stl", 0x0000ff);
    //     defer allocator.free(torus_tris);
    //     var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
    //     torus_mesh.transform.position = storage.V3{ .x = 500, .y = 500, .z = 0 };
    //     torus_mesh.transform.scale = storage.V3{ .x = 3, .y = 3, .z = 3 };
    //     tribuf.insert(torus_mesh, torus_tris);
    //     meshbuf.insert(torus_mesh);
    // }

    // {
    //     const torus_tris = try stl.load_stl(allocator, "bunny.stl", 0x0000ff);
    //     defer allocator.free(torus_tris);
    //     var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
    //     torus_mesh.transform.position = storage.V3{ .x = 200, .y = 200, .z = 0 };
    //     torus_mesh.transform.scale = storage.V3{ .x = 300, .y = 300, .z = 300 };
    //     tribuf.insert(torus_mesh, torus_tris);
    //     meshbuf.insert(torus_mesh);
    // }

    var window = try Window.init(allocator, 1024, 1024);
    defer window.deinit();

    std.log.debug("triangles: {}", .{tribuf.size});

    window.before_loop();
    while (window.loop()) {
        window.set_pixel(50, 100, 0xff0000);
        draw.clear(&window, 0xf0a0bb);
        // meshbuf.buffer[3].transform.rotation.x += 0.005;
        // meshbuf.buffer[3].transform.rotation.y += 0.005;
        // meshbuf.buffer[3].transform.rotation.z += 0.005;

        meshbuf.buffer[0].transform.rotation.y += 0.005;
        meshbuf.buffer[1].transform.rotation.y += 0.005;
        meshbuf.buffer[1].transform.rotation.x += 0.005;
        // meshbuf.buffer[0].transform.rotation.y -= 0.01;
        // meshbuf.buffer[0].transform.rotation.z += 0.005;

        // meshbuf.buffer[2].transform.rotation.x += 0.005;
        // meshbuf.buffer[2].transform.rotation.y += 0.005;
        // meshbuf.buffer[2].transform.rotation.z += 0.005;

        // meshbuf.buffer[4].transform.rotation.y += 0.01;
        // meshbuf.buffer[4].transform.rotation.x += 0.01;

        @memcpy(render_tribuf.buffer, tribuf.buffer);
        draw.draw_orthographic(&window, &render_tribuf, meshbuf);
    }
}
