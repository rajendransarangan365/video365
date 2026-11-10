# Video365 (formerly LibreCuts)

Video365 is a professional-grade, AI-assisted mobile video editor and motion graphics application for Android. It transforms the original LibreCuts foundation into a high-performance NLE (Non-Linear Editor) capable of desktop-class features.

## 🚀 Key Features (Video365 Upgrade)

- **Real-time GPU Render Graph**: Powered by C++ NDK and OpenGL ES 3.2 for 60fps lag-free preview.
- **AI Motion Studio**: On-device face tracking, object tracking, and dolly zoom simulations.
- **Adaptive UI**: A complete Jetpack Compose rewrite supporting dockable panels on tablets and optimized portrait editing on phones.
- **AE-Inspired Expressions**: Embedded QuickJS engine for After Effects-style property animations and JSX templates.
- **Advanced Transitions**: 100+ GLSL-accelerated transitions (Whip Pan, Glitch, Luma Dissolve, etc.).
- **Pro Non-Linear Editing**: Multi-track timeline with parenting, masking, and keyframe Bezier interpolation.

## 🛠️ Architecture

Video365 uses a hybrid architecture:
- **Kotlin/Jetpack Compose**: Handles the UI and high-level project state.
- **C++/NDK**: Manages the real-time render thread, GLSL shaders, and AI inference.
- **Hardware Acceleration**: Deep integration with `MediaCodec` for auto-proxy generation and smart segment caching.

## 📂 Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [Phase 1 Implementation Plan](docs/PHASE_1_PLAN.md)
- [Rendering Engine Details](docs/RENDERING_ENGINE.md)
- [AI Engine Details](docs/AI_ENGINE.md)
- [Project Format (.lcprj v2.0)](docs/PROJECT_FORMAT.md)
- [Feature Matrix](docs/FEATURE_MATRIX.md)
- [Roadmap](docs/ROADMAP.md)

## ⚖️ License

Video365 is forked from LibreCuts and maintains the MIT License for the core application. AI models and third-party libraries (OpenCV, MediaPipe) are subject to their respective licenses.
