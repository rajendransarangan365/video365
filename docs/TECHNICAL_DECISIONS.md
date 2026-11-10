# Video365: Technical Decision Records (TDR)

## TDR 001: Hybrid Rendering Architecture
- **Context:** Mobile video editing requires real-time preview (60fps) with minimal battery drain, but exporting requires high-fidelity frame-accurate encoding.
- **Decision:** Use an OpenGL ES 3.2 C++ Render Graph DAG (`libvideo365_core.so`) via JNI for all preview rendering, effects, and transitions. For export and proxy transcoding, use hardware `MediaCodec` with fallback to `ffmpeg-kit`.
- **Status:** Accepted & Operational.

## TDR 002: Expression Engine Implementation
- **Context:** Desktop After Effects uses JavaScript/QuickJS for expressions like `wiggle(freq, amp)`. Running a full JS VM per frame tick on mobile can introduce garbage collection pauses and JNI overhead.
- **Decision:** Implement a deterministic, zero-allocation C++ expression parser in `expression_engine.cpp` for native math expressions (`wiggle`, `time`, `linear`, `ease`, `loopOut`). Provide JSX preset parsing at the project level to convert declarative JSX templates into timeline layers.
- **Status:** Accepted & Active.

## TDR 003: Shader Standard & Cross-Device Compatibility
- **Context:** Different Android GPU drivers (Adreno, Mali, PowerVR, AMD/Radeon emulator) handle GLSL ES `#version` differently; any whitespace or invalid directive aborts shader compilation.
- **Decision:** Standardize all shaders in `shaders.h` strictly on `#version 300 es` at byte offset 0 with `#extension GL_OES_EGL_image_external_essl3 : require`. This guarantees 100% compatibility across both OpenGL ES 3.0/3.1/3.2 drivers and Android Studio emulators.
- **Status:** Accepted & Verified.

## TDR 004: Dual-Format Serialization & Zero-Regression Policy
- **Context:** Upgrading LibreCuts to Video365 must not break existing `.lcprj` user files or legacy activities.
- **Decision:** Maintain `EditRecipe` Gson serialization for legacy files and `Video365Project` kotlinx.serialization for v2 files in a single unified `ProjectSerializer.kt`.
- **Status:** Accepted & Verified.

## TDR 005: "Render on the Go" Thermal & Proxy Pipeline
- **Context:** 4K/1080p video editing on mobile devices quickly causes thermal throttling and UI stutter.
- **Decision:** Divide timeline into 5-second segments, compute SHA-256 state hashes, pre-render complex segments in the background, and dynamically step down viewport resolution when `PowerManager` reports `THERMAL_STATUS_MODERATE`.
- **Status:** In Progress.

