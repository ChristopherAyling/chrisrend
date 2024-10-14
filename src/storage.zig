const std = @import("std");

pub const V3 = struct {
    x: f32,
    y: f32,
    z: f32,
    pub fn zeros() V3 {
        return V3{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn print(self: V3) void {
        std.log.debug("V3: {d} {d} {d}", .{ self.x, self.y, self.z });
    }
};

pub const Triangle = struct {
    p0: V3, //fmt
    p1: V3,
    p2: V3,
    normal: V3,
    color: u32,
    pub fn print(self: Triangle) void {
        self.normal.print();
        self.p0.print();
        self.p1.print();
        self.p2.print();
        std.log.debug("color {}", .{self.color});
    }
};

pub const TriangleBuffer = struct {
    buffer: []Triangle,
    size: usize = 0,

    pub fn init(triangles: []Triangle) TriangleBuffer {
        return TriangleBuffer{ .buffer = triangles };
    }
    pub fn insert(self: *TriangleBuffer, mesh: Mesh, triangles: []const Triangle) void {
        // self.buffer[mesh.start] = triangles;
        for (0..triangles.len) |i| {
            self.buffer[mesh.start + i] = triangles[i];
        }
    }
};

pub const Mesh = struct {
    start: usize,
    end: usize,
    translation: V3,
    pub fn init(start: usize, end: usize) Mesh {
        return Mesh{ .start = start, .end = end, .translation = V3.zeros() };
    }
};
