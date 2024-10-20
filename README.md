# Chris' Renderer

A software renderer built for learning about computer graphics.


```bash
zig build run
```

features:
- STL Loader
- realtime rendering
- rotation/translation/scaling
- multiple objects
- blinn-phong lighting
- orthographic projection

todo:
- perspective projection
- textures
- draw triangles using barycentric coordinates to avoid current missing of lines
- compiling for WASM
- orbit controls
- match clicks to triangles

Uses https://github.com/zserge/fenster for creating a window. I love fenster.