# Video365 Architecture Guide

## 1. Overview
Video365 is a professional-grade mobile video editor built on top of the LibreCuts foundation. It transitions from a simple FFmpeg wrapper to a real-time GPU-accelerated NLE (Non-Linear Editor) and Motion Graphics engine.

## 2. Core Components

### A. Rendering Pipeline (Hybrid)
*   **Real-time Preview Engine (C++/NDK)**: Uses OpenGL ES 3.2 / Vulkan. Handles compositing, blending modes, and GLSL shaders for effects and transitions.
*   **Media Pipeline (Hardware)**: Utilizes Android `MediaCodec` for hardware-accelerated decoding/encoding and `MediaExtractor` for low-latency scrubbing.
*   **Export Engine (FFmpeg)**: Reserved for final high-quality muxing and complex software-fallback encoding tasks.

### B. UI Layer (Jetpack Compose)
*   **Adaptive Workspace**: Multi-panel layout for tablets, single-column for mobile.
*   **Reactive State**: Using `StateFlow` and `ViewModel` to drive the C++ render thread.
*   **Graph Editor**: Custom Canvas-based Bezier curve editor for keyframe interpolation.

### C. Scripting & Expressions (QuickJS)
*   Embedded QuickJS engine in the NDK layer.
*   Evaluates After Effects-style expressions at 60fps.
*   JSX-based template system for motion graphics.

### D. AI Engine
*   **MediaPipe**: On-device face landmarker and segmentation.
*   **OpenCV**: Feature tracking (KLT) and Optical Flow.
*   **Whisper.cpp**: On-device speech-to-text for transcript-based editing.

## 3. Data Flow
1.  **Input**: User interacts with Compose UI.
2.  **State**: `VideoProject` (v2.0 JSON) updates in Kotlin.
3.  **Sync**: State serialized to NDK via JNI.
4.  **Render**: C++ Render Graph processes frames -> `SurfaceTexture`.
5.  **Output**: Displayed in `AndroidView` (Compose) or exported via `MediaCodec`.

## 4. Performance & Thermal Management
*   **Smart Segment Caching**: Pre-renders complex timeline segments to local storage.
*   **Auto-Proxy**: Background generation of 540p intra-frame proxies.
*   **Thermal API**: Throttles preview resolution and background tasks based on device temperature.
