# OpenCut Ideas & Architecture Integration into Video365

## 1. Executive Summary

By analyzing **OpenCut** (`https://github.com/opencut-app/opencut`), we identified core technical innovations and high-leverage architectural patterns that distinguish OpenCut from traditional editors. We extracted, adapted, and deeply integrated these patterns into **Video365**, combining them with our C++ GLSL hardware rendering pipeline and After Effects motion graphics engine.

---

## 2. The 6 Stolen & Enhanced OpenCut Innovations

### Innovation 1: Model Context Protocol (MCP) AI Video Editor Bridge
* **OpenCut Idea**: Decoupling editor actions into a headless API with tool definitions so autonomous AI agents (Claude Code, Antigravity, Cursor) can script edits.
* **Video365 Implementation**:
  - Implemented in `Video365EditorApi.kt`.
  - Exposes standard MCP tools:
    - `video365_get_project_state`
    - `video365_split_at_playhead`
    - `video365_apply_transition`
    - `video365_apply_lumetri_grade`
    - `video365_add_kinetic_title`
    - `video365_auto_remove_silence`
    - `video365_execute_jsx_script`
  - Returns structured JSON responses that AI agents parse to automate entire editing workflows.

### Innovation 2: In-App Scripting & REPL Console Sheet
* **OpenCut Idea**: An interactive in-app code runner where developers, power users, and AI can run ExtendScript / JSX code against the active sequence.
* **Video365 Implementation**:
  - Built `ScriptingConsoleSheet.kt` with live syntax highlighting, quick preset buttons, and real-time execution log output.
  - Users can test expressions (`wiggle(3.0, 25.0)`), manipulate timeline tracks (`app.project.activeSequence.splitAtPlayhead()`), or trigger batch operations directly in-app.

### Innovation 3: Audio Waveform Loudness Profiling
* **OpenCut Idea**: Real-time RMS audio amplitude visualization along track bars instead of flat color strips.
* **Video365 Implementation**:
  - Enhanced `Timeline.kt`'s `LayerTrack` with a sub-sampled Canvas drawing amplitude bars directly on `VIDEO` and `AUDIO` track layers.
  - Matches the visual density and responsive scrubbing of OpenCut and Premiere Pro.

### Innovation 4: Smart Silence Remover (Auto-Cut)
* **OpenCut Idea**: Automatically detecting pauses and silence in dialog tracks and ripple-deleting the gaps.
* **Video365 Implementation**:
  - `Video365EditorApi.autoDetectSilenceSegments()` scans timestamps and automatically splits and ripples the timeline clips.
  - Accessible via 1-tap in the Scripting Console or Command Palette.

### Innovation 5: Plugin-First Modular Shader & Preset Engine
* **OpenCut Idea**: Standardized interface for GLSL transitions and animation presets.
* **Video365 Implementation**:
  - Integrated 10 GPU GLSL shaders (`whip_pan`, `glitch`, `doorway`, `zoom`, `film_burn`, `radial_blur`, `swirl`, `wave`, `wipe`, `dissolve`) via `Video365Engine` and `TransitionPreviewCanvas`.
  - Modular JSX motion graphics presets (`kinetic_title`, `lower_third`, `social_callout`, `glitch_intro`) instantiated via `JsxPresetEngine`.

### Innovation 6: Zero-Black-Screen Hardware Viewport Compositing
* **OpenCut Idea**: Decoupling the video decoding pipeline from the compositing and overlay pipeline.
* **Video365 Implementation**:
  - Uses direct hardware ExoPlayer decoding via `StyledPlayerView` with `BoxWithConstraints` bounding fit.
  - Transparent `MotionGraphicsViewportOverlay` renders Lumetri color grading, vignette, transitions, and kinetic typography on top without intercepting or stalling video frames.

---

## 3. Comparison Matrix: OpenCut vs. Video365

| Feature | OpenCut | Video365 Mobile |
| :--- | :--- | :--- |
| **Platform** | Desktop (Tauri / Rust / React) | Android Native (Kotlin + C++ NDK + Compose) |
| **Video Decoding** | FFmpeg / Rust Pipeline | Android MediaCodec Hardware Acceleration |
| **Compositing** | WebGL / Canvas2D | C++ OpenGL ES 3.0 + Compose Canvas Overlay |
| **AE Expressions** | Basic JS Math | C++ AST Recursive Descent Evaluator (`wiggle`, `loopOut`) |
| **MCP Server** | Standalone JSON-RPC | In-App `Video365EditorApi` + JSON Dispatcher |
| **REPL Console** | Browser DevTools / Tab | Mobile Bottom Sheet Modal with Presets & Log Terminal |
| **Audio Waveforms** | WebAudio Canvas | Native Android Compose Canvas RMS Peak Visualizer |
| **Thermal Protection** | Desktop CPU Throttling | Android Thermal API 5-Second Segment Cache ("Render on the Go") |

