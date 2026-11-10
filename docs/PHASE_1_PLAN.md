# Video365 Phase 1 Implementation Plan

## Objective
Establish the hybrid NDK/Kotlin foundation and migrate the core project model to v2.0.

## 1. NDK & Core Engine Setup
*   **Task 1.1**: Add CMake and C++ support to `app/build.gradle`.
*   **Task 1.2**: Create `src/main/cpp/video365_core.cpp` and `video365_renderer.cpp`.
*   **Task 1.3**: Implement the JNI bridge for passing the `VideoProject` state.
*   **Task 1.4**: Embed QuickJS in the NDK layer.

## 2. Project Model v2.0
*   **Task 2.1**: Rewrite `com.tharunbirla.librecuts.models.VideoProject` to match the JSON schema in `plan.md`.
*   **Task 2.2**: Implement `ProjectSerializer` using `kotlinx.serialization` for fast JSON I/O.
*   **Task 2.3**: Update `VideoEditingViewModel` to hold the new state.

## 3. Real-time Preview Hook
*   **Task 3.1**: Create `Video365PreviewView` (Jetpack Compose) using `AndroidView` + `TextureView`.
*   **Task 3.2**: Hook into ExoPlayer's `setVideoFrameMetadataListener` to send frames to the NDK renderer.
*   **Task 3.3**: Implement initial GLSL "Dissolve" and "Fade" transitions in C++.

## 4. Adaptive UI Foundation
*   **Task 4.1**: Create `EditorScreen.kt` in Jetpack Compose.
*   **Task 4.2**: Implement a basic multi-track timeline component with scroll/zoom logic.
*   **Task 4.3**: Add the aspect ratio selector dialog on startup.

## Success Metrics
*   App launches into a vertical/horizontal project selector.
*   Scrubbing a video shows a 60fps preview through the C++ shader pipeline.
*   Project state can be saved/loaded in the new v2.0 format.
