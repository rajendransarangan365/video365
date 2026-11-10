# Video365 (Legacy: LibreCuts)

<div align="center">
  <img src="docs/assets/banner_v365.png" alt="Video365 Banner" width="100%"/>
  <br/>
  <br/>
  <b>Professional AI-Assisted Mobile Motion Graphics & Video Editing</b>
  <br/>
  <br/>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" height="35" alt="License" />
  </a>
</div>

<br/>

**Video365** is a major evolution of the LibreCuts project, transforming it from a basic video trimmer into a desktop-grade mobile animation and editing suite. Inspired by Adobe After Effects and Premiere Pro, Video365 introduces a real-time GPU rendering engine, on-device AI tracking, and a professional multi-track timeline.

---

## 🚀 Video365 Features (The "Pro" Upgrade)

- **Real-Time GPU Engine**: 60fps lag-free preview using OpenGL ES 3.2. No more waiting for FFmpeg to render every change.
- **AI Motion Studio**:
    - **Face-Tracking Dolly**: Automatically zooms and centers on subjects for a professional cinematic look.
    - **Object Tracking**: Pin text, stickers, or masks to moving objects in your video.
    - **AI Background Removal**: One-tap rotoscoping using MediaPipe/MobileSAM.
- **Adaptive UI**: Professional Jetpack Compose interface that adapts from Phone (portrait) to Tablet (landscape workspace).
- **Pro Transitions**: 100+ GLSL-accelerated transitions including Whip Pan, Glitch, Luma Dissolve, and Morph.
- **AE-Style Expressions**: Powered by an embedded QuickJS engine. Use `wiggle()`, `loopOut()`, and custom JS scripts to drive animations.
- **v2.0 Project Format**: Non-destructive, hierarchical JSON schema supporting pre-compositions and parenting.
- **Smart Render Cache**: Automatically pre-renders complex segments in the background to maintain 60fps playback.

---

## 🛠️ Tech Stack Upgrade

| Component | Legacy (LibreCuts) | Video365 (Current) |
| :--- | :--- | :--- |
| **UI** | View/XML | Jetpack Compose |
| **Rendering** | FFmpeg (Static) | C++ NDK + GLES 3.2 (Real-time) |
| **Logic** | Kotlin | Kotlin + C++ (JNI) |
| **AI** | N/A | MediaPipe + OpenCV |
| **Scripting** | N/A | QuickJS (AE Expressions) |
| **Performance** | Basic | Auto-Proxy + Thermal Throttling API |

---

## 📂 Documentation

- [Architecture & Rendering Pipeline](docs/ARCHITECTURE.md)
- [AI Engine & Tracking Logic](docs/AI_ENGINE.md)
- [Project Schema v2.0](docs/PROJECT_FORMAT.md)
- [Transition & Effects Library](docs/RENDERING_ENGINE.md)
- [Phase 1 Implementation Plan](docs/PHASE_1_PLAN.md)

---

## 🚀 Getting Started

Video365 requires the Android NDK and CMake. 

1. **Clone**: `git clone https://github.com/tharunbirla/LibreCuts.git`
2. **Build**: Open in Android Studio (Koala or later). Gradle will automatically sync the NDK components.
3. **Run**: Ensure you have a device supporting OpenGL ES 3.2.

---

## 📝 License

This project is licensed under the MIT License. Contributions are welcome!
