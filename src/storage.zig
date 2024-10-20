const std = @import("std");

pub const Quat = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
    pub fn identity() Quat {
        return Quat{ .x = 0, .y = 0, .z = 0, .w = 1 };
    }
};

pub const Mat4x4 = struct {
    data: [4][4]f32,

    pub fn set(self: *Mat4x4, i: u32, j: u32, value: f32) void {
        self.data[i][j] = value;
    }

    pub fn get(self: Mat4x4, i: u32, j: u32) f32 {
        return self.data[i][j];
    }

    pub fn zeroes() Mat4x4 {
        return std.mem.zeroInit(Mat4x4, .{});
    }

    pub fn identity() Mat4x4 {
        return Mat4x4{ .data = .{
            .{ 1, 0, 0, 0 },
            .{ 0, 1, 0, 0 },
            .{ 0, 0, 1, 0 },
            .{ 0, 0, 0, 1 },
        } };
    }

    pub fn print(self: Mat4x4) void {
        for (0..4) |i| {
            std.log.debug("{any}", .{self.data[i]});
        }
    }

    pub fn perspective(fovy_in_degrees: f32, aspect_ratio: f32, z_near: f32, z_far: f32) Mat4x4 {
        var result = Mat4x4.identity();

        const f = 1 / @tan(std.math.degreesToRadians(fovy_in_degrees) * 0.5);

        result.data[0][0] = f / aspect_ratio;
        result.data[1][1] = f;
        result.data[2][2] = (z_near + z_far) / (z_near - z_far);
        result.data[2][3] = -1;
        result.data[3][2] = 2 * z_far * z_near / (z_near - z_far);
        result.data[3][3] = 0;

        return result;
    }
};

pub fn mul_mat_vec(mat: Mat4x4, vec: V3) V3 {
    return V3.init(
        mat.get(0, 0) * vec.x + mat.get(0, 1) * vec.y + mat.get(0, 2) * vec.z + mat.get(0, 3) * 1,
        mat.get(1, 0) * vec.x + mat.get(1, 1) * vec.y + mat.get(1, 2) * vec.z + mat.get(1, 3) * 1,
        mat.get(2, 0) * vec.x + mat.get(2, 1) * vec.y + mat.get(2, 2) * vec.z + mat.get(2, 3) * 1,
    );
}

pub const V3 = struct {
    x: f32,
    y: f32,
    z: f32,
    pub fn init(x: f32, y: f32, z: f32) V3 {
        return V3{ .x = x, .y = y, .z = z };
    }
    pub fn zeros() V3 {
        return V3{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn ones() V3 {
        return V3{ .x = 1, .y = 1, .z = 1 };
    }

    pub fn somes(n: f32) V3 {
        return V3{ .x = n, .y = n, .z = n };
    }

    pub fn print(self: V3) void {
        std.log.debug("V3: {d} {d} {d}", .{ self.x, self.y, self.z });
    }

    pub fn add(self: V3, other: V3) V3 {
        return V3{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
    }

    pub fn mul(self: V3, other: V3) V3 {
        return V3{ .x = self.x * other.x, .y = self.y * other.y, .z = self.z * other.z };
    }

    pub fn dot(self: V3, other: V3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn div(self: V3, other: V3) V3 {
        return V3{ .x = self.x / other.x, .y = self.y / other.y, .z = self.z / other.z };
    }

    pub fn sub(self: V3, other: V3) V3 {
        return V3{ .x = self.x - other.x, .y = self.y - other.y, .z = self.z - other.z };
    }

    pub fn neg(self: V3) V3 {
        return V3{ .x = -self.x, .y = -self.y, .z = -self.z };
    }

    pub fn cross(self: V3, other: V3) V3 {
        return V3{ .x = self.y * other.z - self.z * other.y, .y = self.z * other.x - self.x * other.z, .z = self.x * other.y - self.y * other.x };
    }

    pub fn normalize(self: V3) V3 {
        return self.div(V3.somes(self.length()));
    }

    pub fn length(self: V3) f32 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    pub fn reflect(self: V3, normal: V3) V3 {
        // I - 2*dot(N,I)*N
        const dotp = V3.somes(self.dot(normal));
        const dot_2 = dotp.mul(V3.somes(2));
        const dot_2_n = dot_2.mul(normal);
        return self.sub(dot_2_n);
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

    pub fn calc_normal(self: Triangle) V3 {
        const v1 = self.p1.sub(self.p0);
        const v2 = self.p2.sub(self.p0);
        const cross = v1.cross(v2);
        return cross.normalize();
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
        self.size += triangles.len;
    }
};

pub const Transform = struct {
    position: V3,
    // rotation: Quat,
    rotation: V3,
    scale: V3,
    pub fn identity() Transform {
        return Transform{
            .position = V3.zeros(),
            // .rotation = Quat.identity(),
            .rotation = V3.zeros(),
            .scale = V3.ones(),
        };
    }
};

pub const Mesh = struct {
    start: usize,
    end: usize,
    transform: Transform,
    pub fn init(start: usize, end: usize) Mesh {
        return Mesh{ .start = start, .end = end, .transform = Transform.identity() };
    }
};

pub const MeshBuffer = struct {
    buffer: []Mesh,
    size: usize = 0,

    pub fn init(meshes: []Mesh) MeshBuffer {
        return MeshBuffer{ .buffer = meshes };
    }

    pub fn insert(self: *MeshBuffer, mesh: Mesh) void {
        self.buffer[self.size] = mesh;
        self.size += 1;
    }
};
