import trimesh

# Parameters for the torus
major_radius = 1.0  # The radius from the center to the middle of the tube
minor_radius = 0.3  # The radius of the tube itself

# Create a torus mesh
torus_mesh = trimesh.creation.torus(major_radius=major_radius, minor_radius=minor_radius)

# Show the mesh
torus_mesh.export('torus.stl')

# cylinder
cylinder_mesh = trimesh.creation.cylinder(radius=3, height=2.0)
cylinder_mesh.export('cylinder.stl')