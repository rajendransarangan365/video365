# Video365 Feature Matrix

| Feature Category | LibreCuts (Baseline) | Video365 (Target) | Priority |
| :--- | :--- | :--- | :--- |
| **UI Framework** | View-based (XML) | Jetpack Compose (Adaptive) | High |
| **Preview Engine** | FFmpeg sessions (Static) | C++/NDK OpenGL ES 3.2 (Real-time) | Critical |
| **Timeline** | Single-track / Simple | Multi-track / Parent-Child layers | High |
| **Transitions** | FFmpeg filters (Slow) | GLSL Shaders (Instant, 100+) | High |
| **Animation** | Lottie (External) | Custom Keyframe Engine + Graph Editor | Critical |
| **Color Grading** | N/A | Lumetri-style (LUTs, Curves, Wheels) | Medium |
| **Audio** | Basic FFmpeg | Google Oboe DSP (EQ, Compressor) | Medium |
| **AI Tracking** | N/A | MediaPipe Face/Object Tracking | High |
| **Background Removal** | N/A | AI-based (MobileSAM / MediaPipe) | Medium |
| **Scripting** | N/A | QuickJS (AE Expressions / JSX Templates) | Critical |
| **Performance** | Basic | Auto-Proxy + Smart Segment Caching | High |
| **Transcription** | N/A | Whisper.cpp (On-device) | Medium |
