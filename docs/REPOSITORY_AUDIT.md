# Video365: Repository & Source Code Audit

## 1. Overview & Baseline Identification
- **Upstream Repository:** `https://github.com/tharunbirla/LibreCuts.git`
- **Application Target:** Video365 (After Effects 2026 + Premiere Pro Mobile/Tablet Editor)
- **Target OS:** Android 10+ (API 29–35), Tested on Android 15 (API 35, x86_64, arm64-v8a)
- **Primary Toolchains:**
  - Android Gradle Plugin 8.7.2 + Gradle 9.7.1
  - Kotlin 2.0.21 + Jetpack Compose (BOM 2024.10.00)
  - Android NDK 27.0.12077973 + CMake 3.22.1+
  - C++ standard: C++17 (OpenGL ES 3.2, EGL)

---

## 2. Technical Inventory by Subsystem

### 2.1 Android Application Architecture
- **Legacy Framework:** Single Activity + Multiple Activities for modal workflows (`MainActivity`, `VideoEditingActivity`, `ProjectImportActivity`, `ErrorDisplayActivity`).
- **Modernized Video365 Framework:** `Video365EditingActivity` with Jetpack Compose declarative UI (`EditorScreen.kt`), reactive `Video365ViewModel` exposing Kotlin `StateFlow`, and JNI bridge `Video365Engine`.
- **Packaging & Branding:** `com.tharunbirla.librecuts` preserved for backwards compatibility and keystore persistence; user-facing identity upgraded to Video365.

### 2.2 Programming Languages & Components
- **Kotlin (70%):** ViewModels, Compose UI (`Timeline`, `GraphEditor`, `CommandBar`), MediaStore queries, MediaPipe wrappers.
- **C++17 (25%):** Render Graph DAG (`render_graph.cpp`), shader compiler (`video365_renderer.cpp`), math library (`glm/glm.hpp`), expression engine (`expression_engine.cpp`).
- **Java (5%):** Legacy custom views (`ImageOverlayView`, `MaskedFrameLayout`).

### 2.3 Video Decoding & Playback
- **Playback Engine:** AndroidX ExoPlayer (Media3 compatibility).
- **NDK Interop:** Backed by `SurfaceTexture` + OpenGL ES `GL_TEXTURE_EXTERNAL_OES` (`samplerExternalOES`). Frames from ExoPlayer decode directly into native GPU texture memory for sub-frame shader processing.

### 2.4 Rendering Engine & GPU Acceleration
- **Legacy:** Subprocess execution of `ffmpeg-kit-full-gpl` CLI commands. Heavy, non-interactive, and battery-intensive.
- **Modernized Video365:** Real-time C++ Render Graph DAG (`libvideo365_core.so`) using OpenGL ES 3.2 on EGL window surfaces. Zero IPC overhead for preview rendering.

### 2.5 Timeline & Track Models
- **Legacy:** Flat linear sequence (`EditRecipe`, `TimelineSegment`).
- **Modernized Video365:** Multi-track composition hierarchy (`Video365Project`, `Composition`, `Layer`) supporting layer parenting (`parentId`), in/out points, 3D flags, transform keyframes, and mask tracks.

### 2.6 Effects & Transitions
- **GLSL Fragment Shaders:**
  - *Transitions:* Cross Dissolve, Whip Pan, Procedural Glitch, Zoom In/Out, Film Burn, Radial Blur.
  - *Effects:* Lumetri Color (Exposure, Contrast, Saturation, Balance Tint), Chromatic Aberration.
  - *AI Effects:* Dolly Zoom, Object Tracking bounding overlay.

### 2.7 AI Capabilities
- **On-Device Vision:** Google MediaPipe Tasks Vision (`FaceLandmarker` with `face_landmarker.task` model).
- **Hardware Fallback:** Multi-architecture safety catching `Throwable` on platforms lacking specific native vendor delegates.

### 2.8 Project Persistence & Schema
- **Legacy Format:** `.lcprj` (Gson-serialized `EditRecipe`).
- **Modern Format:** `Video365Project` v2 JSON (`kotlinx.serialization`).
- **Compatibility:** Dual-engine `ProjectSerializer` automatically detects and deserializes both legacy and v2 formats without data loss.

---

## 3. Performance & Bottlenecks Audit
1. **Shader #version Syntax:** Addressed strict GLSL ES 3.00 `#version 300 es` requirements to prevent emulator driver compilation aborts.
2. **GLM Availability:** Replaced missing system GLM with clean header-only column-major vector/matrix library.
3. **Thermal Throttling:** Master blueprint mandates proxy media and smart segment caching to avoid overheating during multi-layer composition.

