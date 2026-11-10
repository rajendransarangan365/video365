# Video365: Current System Architecture

## 1. System Topology

```mermaid
graph TD
    subgraph UI ["Jetpack Compose Presentation Layer"]
        A[MainActivity / Onboarding] --> B[ProjectCreationDialog]
        B --> C[Video365EditingActivity]
        C --> D1[PhoneWorkspace]
        C --> D2[TabletWorkspace]
        C --> CB[CommandBar Quick Search]
        C --> GE[GraphEditor]
        C --> TL[Timeline & Layer Tracks]
    end

    subgraph State ["Domain & State Layer"]
        VM[Video365ViewModel] --> VP[Video365Project v2 Schema]
        VP --> PS[ProjectSerializer]
        PS <--> Legacy[Legacy .lcprj Backward Compatibility]
    end

    subgraph NativeBridge ["JNI Integration Bridge"]
        V365E[Video365Engine.kt] <--> CoreJNI[video365_core.cpp]
    end

    subgraph RenderCore ["C++ Real-Time Render Engine (libvideo365_core.so)"]
        CoreJNI --> RG[RenderGraph DAG]
        RG --> VBO[Mesh / Geometry]
        RG --> Shaders[GLSL ES 3.00 Shader Engine]
        RG --> Math[GLM Math Core]
        RG --> EE[Expression Engine / Wiggle Evaluator]
        RG --> EGLContext[EGL Display Surface]
    end

    subgraph Media ["Playback & AI Subsystems"]
        Exo[ExoPlayer / MediaCodec] --> Surface[SurfaceTexture / OES Texture]
        Surface --> Shaders
        FTP[FaceTrackingProcessor] --> MediaPipe[MediaPipe FaceLandmarker]
        MediaPipe --> Dolly[Dolly Zoom & Face Center]
        Dolly --> V365E
    end

    D1 --> V365E
    D2 --> V365E
    CB --> V365E
    VM --> V365E
```

---

## 2. Component Breakdown

### 2.1 UI Presentation Layer
- **`ProjectCreationDialog.kt`**: Prompts the user on startup for aspect ratio configurations (`9:16`, `16:9`, `1:1`, `4:5`).
- **`EditorScreen.kt`**: Breakpoint-based responsive layout:
  - Phone (<600dp): Preview viewport, Action Toolbar (`Trim`, `Split`, `FX`, `AI Dolly`, `⚡ Commands`), and single-scroll multi-track timeline.
  - Tablet (≥600dp): Multi-column studio workspace with Project Bin, Viewport, Timeline, Effect Controls, and `GraphEditor`.
- **`CommandBar.kt`**: Mobile equivalent of After Effects `Ctrl+Enter` fuzzy search palette.
- **`GraphEditor.kt`**: Interactive Bézier curve and tangent handles for keyframe interpolation.

### 2.2 Native C++ Engine (`libvideo365_core.so`)
- **`video365_renderer.cpp`**: Configures EGL context (`EGL_CONTEXT_CLIENT_VERSION = 3`), compiles vertex/fragment shaders, manages OES textures, and runs the render loop.
- **`render_graph.cpp`**: Maintains node dependencies, layer stack matrices (`WorldMatrix = ParentMatrix * LocalMatrix`), blend modes, and opacity.
- **`shaders.h`**: Comprehensive GLSL ES 3.00 shader definitions for transitions (Glitch, Whip Pan, Dissolve, Zoom, Film Burn, Radial Blur) and effects (Lumetri Color, Chromatic Aberration, Dolly Zoom, Object Track).
- **`expression_engine.cpp`**: High-speed C++ expression evaluator for per-frame mathematics and `wiggle(freq, amp)`.

### 2.3 Serialization & Data Compatibility
- **`ProjectModels.kt`**: Full v2 JSON schema with compositions, layers, keyframes, expressions, render cache segments, and thermal policies.
- **`ProjectSerializer.kt`**: Dual-parser preserving legacy `.lcprj` format and serializing/deserializing v2 project files.

