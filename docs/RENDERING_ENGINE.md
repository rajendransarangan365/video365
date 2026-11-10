# Video365 Rendering Engine (libvideo365_core)

## 1. Goal
Achieve 60fps real-time preview with support for multi-layer compositing, blending, and GLSL effects.

## 2. Technical Stack
*   **OpenGL ES 3.2**: Primary rendering API for Android.
*   **EGL**: For managing display surfaces and contexts.
*   **Google Filament**: Integrated as a sub-renderer for true 3D layers and PBR materials.
*   **Hardware Buffers**: Using `AHardwareBuffer` for zero-copy texture sharing between `MediaCodec` and the GL pipeline.

## 3. Render Graph Architecture
The engine maintains a directed acyclic graph (DAG) of render passes:
1.  **Source Nodes**: Decoded video frames (from `SurfaceTexture`), SVG rasterizers, and generated shapes.
2.  **Filter Nodes**: GLSL fragment shaders (Lumetri Color, Blur, Glitch).
3.  **Compositor Node**: Blends all layers based on parenting, opacity, and blend modes (Multiply, Screen, Overlay).
4.  **Output Node**: Renders to the UI's `TextureView` or an `ImageReader` for export.

## 4. GLSL Effect Structure
All effects are modular `.glsl` files.
Example uniform block:
```glsl
layout(std140) uniform EffectParams {
    float u_time;
    float u_progress;
    vec2 u_resolution;
    float u_intensity;
};
```

## 5. Smart Segment Caching
If a segment of the timeline is too complex to render in real-time (<16ms), the engine:
1.  Triggers a background hardware encode of that 5s segment.
2.  Caches the result as `seg_{hash}.mp4`.
3.  Replaces the graph branch with a single video source node for playback.
