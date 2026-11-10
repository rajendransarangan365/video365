# Reverse Engineering Audit: LibreCuts & REA

## 1. LibreCuts Analysis
LibreCuts is primarily a high-level wrapper around FFmpeg.
*   **Media Handling**: Uses `MediaMetadataRetriever` for basic info and `ExoPlayer` for playback.
*   **Editing Logic**: Commands are translated into complex FFmpeg strings.
*   **Bottleneck**: Real-time feedback is missing. Every "Apply" button triggers a background FFmpeg task.
*   **UI**: View-based, making complex timeline interactions (like parenting or graph editing) difficult to implement and maintain.

## 2. REA (Reverse Engineering Toolkit) Utilization
The `rea` repository provides advanced hooks and native debugging capabilities.
*   **JNI Bridging**: We will use the patterns found in `rea/native` to establish a high-performance bridge between Kotlin and C++.
*   **Frida Scripts**: Useful for profiling existing hardware codec behavior on various Android devices during the "Auto-Proxy" implementation.
*   **Security Auditing**: The toolkit will be used to ensure our JSX sandbox (QuickJS) is secure and doesn't leak memory or access unauthorized system resources.

## 3. Transformation Strategy
Instead of starting from scratch, we will:
1.  **Intercept the Preview**: Replace `StyledPlayerView` with a custom `GLSurfaceView` or `TextureView` that consumes ExoPlayer's frames but passes them through our C++ Render Graph.
2.  **State Centralization**: Move the fragmented UI state into a single `VideoProject` v2.0 schema that both Kotlin and C++ can read.
3.  **Modular Effects**: Re-implement FFmpeg filters as GLSL shaders for instant feedback.
