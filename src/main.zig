const std = @import("std");
const Window = @import("window.zig").Window;
const storage = @import("storage.zig");
const stl = @import("stl.zig");
const draw = @import("draw.zig");
const text = @import("text.zig");

const Command = enum { none, up, down, left, right };

pub fn mesh_id_from_triangle_id(id: u32, tribuf: storage.TriangleBuffer, meshbuf: storage.MeshBuffer) u32 {
    for (0..meshbuf.size) |i| {
        const mesh = meshbuf.buffer[i];
        const triangles = tribuf.buffer[mesh.start..mesh.end];
        for (triangles) |triangle| {
            if (triangle.id == id) {
                return @intCast(i);
            }
        }
    }
    return 3;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    const tris = try allocator.alloc(storage.Triangle, 10_000_000);
    defer allocator.free(tris);
    var tribuf = storage.TriangleBuffer.init(tris);

    const render_tris = try allocator.alloc(storage.Triangle, 10_000_000);
    defer allocator.free(render_tris);
    var render_tribuf = storage.TriangleBuffer.init(render_tris);

    const meshes = try allocator.alloc(storage.Mesh, 10);
    defer allocator.free(meshes);
    var meshbuf = storage.MeshBuffer.init(meshes);

    // {
    //     const torus_tris = try stl.load_stl(allocator, "torus.stl", 0x0000ff);
    //     defer allocator.free(torus_tris);
    //     var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
    //     torus_mesh.transform.position = storage.V3{ .x = 200, .y = 200, .z = -100 };
    //     torus_mesh.transform.scale = storage.V3{ .x = 300, .y = 300, .z = 300 };
    //     tribuf.insert(torus_mesh, torus_tris);
    //     meshbuf.insert(torus_mesh);
    // }

    {
        const torus_tris = try stl.load_stl(allocator, "bunny.stl", 0x008080);
        defer allocator.free(torus_tris);
        var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
        torus_mesh.transform.position = storage.V3{ .x = 500, .y = 500, .z = 0 };
        torus_mesh.transform.scale = storage.V3{ .x = 3, .y = 3, .z = 3 };
        tribuf.insert(torus_mesh, torus_tris);
        meshbuf.insert(torus_mesh);
    }

    {
        const torus_tris = try stl.load_stl(allocator, "bunny.stl", 0x008080);
        defer allocator.free(torus_tris);
        var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
        torus_mesh.transform.position = storage.V3{ .x = 500, .y = 500, .z = 0 };
        torus_mesh.transform.scale = storage.V3{ .x = 3, .y = 3, .z = 3 };
        tribuf.insert(torus_mesh, torus_tris);
        meshbuf.insert(torus_mesh);
    }

    // {
    //     const torus_tris = try stl.load_stl(allocator, "SWRat.stl", 0xffA500);
    //     defer allocator.free(torus_tris);
    //     var torus_mesh = storage.Mesh.init(tribuf.size, tribuf.size + torus_tris.len);
    //     torus_mesh.transform.position = storage.V3{ .x = 500, .y = 500, .z = 200 };
    //     torus_mesh.transform.scale = storage.V3{ .x = 500, .y = 500, .z = 500 };
    //     torus_mesh.transform.rotation.x = std.math.degreesToRadians(90);
    //     tribuf.insert(torus_mesh, torus_tris);
    //     meshbuf.insert(torus_mesh);
    // }

    for (0..tribuf.size) |i| {
        tribuf.buffer[i].id = @intCast(i);
    }

    var window = try Window.init(allocator, 1024, 1024);
    defer window.deinit();

    std.log.debug("triangles: {}", .{tribuf.size});

    const UP = 17;
    const DOWN = 18;
    const LEFT = 20;
    const RIGHT = 19;

    window.before_loop();
    var t: f32 = 0;
    while (window.loop()) {
        // std.log.debug("{any}", .{window.f.keys});
        // for (window.f.keys, 0..) |k, i| {
        //     if (k == 0) continue;
        //     std.log.debug("{d} {d}", .{ i, k });
        // }
        var command = Command.none;
        if (window.key(UP)) {
            command = Command.up;
        }
        if (window.key(DOWN)) {
            command = Command.down;
        }
        if (window.key(LEFT)) {
            command = Command.left;
        }
        if (window.key(RIGHT)) {
            command = Command.right;
        }
        const movement_magnitude = 10;
        const camera_location_delta: storage.V3 = switch (command) {
            .none => storage.V3.zeros(),
            .left => storage.V3.init(movement_magnitude, 0, 0),
            .right => storage.V3.init(-movement_magnitude, 0, 0),
            .up => storage.V3.init(0, 0, -movement_magnitude),
            .down => storage.V3.init(0, 0, movement_magnitude),
        };

        for (meshbuf.buffer) |*mesh| {
            mesh.transform.position = mesh.transform.position.add(camera_location_delta);
        }

        meshbuf.buffer[0].transform.rotation.x += 0.005;
        meshbuf.buffer[0].transform.rotation.y += 0.01;
        meshbuf.buffer[1].transform.rotation.x += 0.005;
        meshbuf.buffer[1].transform.rotation.y += 0.01;

        @memcpy(render_tribuf.buffer, tribuf.buffer);
        render_tribuf.size = tribuf.size;

        // const mouse_x = window.f.x;
        // const mouse_y: i32 = window.f.y;

        // std.log.debug("mouse_x: {d}, mouse_y: {d}", .{ mouse_x, mouse_y });
        // if (mouse_x > 0 and mouse_y > 0 and mouse_x < window.w and mouse_y < window.h) {
        //     const triangle_id = window.get_triangle_id(@intCast(mouse_x), @intCast(mouse_y));
        //     std.log.debug("triangle_id {d} and render_tribuf.size {d}", .{ triangle_id, render_tribuf.size });
        //     if (triangle_id < render_tribuf.size) {
        //         const mesh_id = mesh_id_from_triangle_id(triangle_id, render_tribuf, meshbuf);
        //         const mesh = meshbuf.buffer[mesh_id];
        //         for (mesh.start..mesh.end) |i| {
        //             render_tribuf.buffer[i].color = 0x00ff00;
        //             render_tribuf.buffer[i] = render_tribuf.buffer[i].move_along_vector(render_tribuf.buffer[i].calc_normal(), 10);
        //         }
        //     }
        // }
        const mesh = meshbuf.buffer[0];
        for (mesh.start..mesh.end) |i| {
            render_tribuf.buffer[i].color = 0x00ff00;
            const distance: f32 = @sin(t / 20.0) * 20.0 + 20;
            render_tribuf.buffer[i] = render_tribuf.buffer[i].move_along_vector(render_tribuf.buffer[i].calc_normal(), distance);
        }

        draw.clear(&window, 0xaa6f73);
        draw.draw_orthographic(&window, &render_tribuf, meshbuf);
        t += 1;
    }
}
