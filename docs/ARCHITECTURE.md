# VIDEO365 — MASTER ARCHITECTURAL BLUEPRINT & FLUTTER SYSTEM SPECIFICATION

## Executive Overview
**Video365** is a professional mobile video editing and motion graphics workstation inspired by Adobe Premiere Pro, After Effects, and modern touch-first mobile suites (CapCut, Feelsy). It is architected for Android using a hybrid **Flutter UI + Native GPU/NDK Rendering Engine** with offline-first AI and JSX expression scripting.

---

## 1. Repository Audit Report

| Component | Existing Native Implementation (`LibreCuts`) | Target Flutter Architecture (`video365`) | Migration Strategy |
|---|---|---|---|
| **UI Framework** | Jetpack Compose + Material 3 | Flutter 3.47 / Dart 3.13 + Riverpod | Clean, modular Flutter UI matching attached UI reference |
| **Theme / Design** | Dark Slate / Cyan | Deep Charcoal (`#080A0E`) + Neon Green (`#20C878`) | Custom Video365 Design System matching attached reference |
| **Timeline Engine** | Android Compose Canvas with density scaling | CustomPainter + Flutter RenderBox virtualized timeline | Sub-millisecond rational frame calculations, multi-track |
| **Motion Graphics** | C++ expression parser (`wiggle`, `time*45`) | C++ NDK shared engine via Dart FFI / Platform Channels | Reusable C++ expression and JSX scripting engine |
| **Media Playback** | ExoPlayer (SurfaceView / StyledPlayerView) | Texture-backed native video decoder / MediaCodec | Frame-accurate preview surface |
| **Color Grading** | GLSL Lumetri & Vignette shaders | OpenGL ES / Vulkan fragment shaders | Real-time GPU shader pipeline |
| **Project Persistence** | Kotlinx Serialization JSON (`2.0.0`) | Versioned JSON format with integer frame timebases | Interoperable project schema |

---

## 2. Proposed Flutter Folder Structure

```
video365/
├── android/                         # Native Android host & NDK integration
│   ├── app/src/main/
│   │   ├── cpp/                    # Shared C++ Render Graph & Expression Engine
│   │   ├── kotlin/                 # MediaCodec, AudioTrack, TextureRegistry bridge
│   │   └── res/mipmap-*/           # Official Video365 App Icon
├── assets/
│   ├── fonts/                      # Outfit / Inter / Fira Code
│   ├── icons/                      # Vector assets
│   ├── presets/                    # Motion graphics & transition presets
│   └── samples/                    # Sample 4K/1080p demo footage
├── docs/                           # Living project documentation
│   ├── ARCHITECTURE.md
│   ├── TIMELINE_ENGINE.md
│   └── UI_UX_GUIDELINES.md
├── lib/
│   ├── core/
│   │   ├── constants/              # Dimensions, aspect ratios, frame rates
│   │   ├── theme/                  # Video365Colors, Video365Typography, AppTheme
│   │   ├── utils/                  # Timecode formatters, math, bezier curves
│   │   └── widgets/                # Buttons, sliders, dials, modal sheets
│   ├── features/
│   │   ├── audio/                  # Waveform visualization, ducking, recording
│   │   ├── captions/               # Auto-captions, karaoke highlighter, SRT
│   │   ├── color/                  # Scopes (RGB parade, histogram), LUTs, wheels
│   │   ├── dashboard/              # Home projects list, recent media, new project
│   │   ├── editor/                 # Main studio workspace, top bar, preview card
│   │   ├── export/                 # Bitrate, resolution, codec, progress sheet
│   │   ├── media_browser/          # Gallery, album picker, audio browser
│   │   ├── motion_graphics/        # Keyframes, graph editor, JSX presets
│   │   ├── radial_menu/            # Circular touch wheel editing control
│   │   ├── timeline/               # Multi-track virtualizer, playhead, clip card
│   │   └── transitions/            # Transition browser & custom creator
│   ├── models/
│   │   ├── project.dart            # Video365Project, ProjectMeta
│   │   ├── composition.dart        # Composition, Layer, Transform
│   │   ├── keyframe.dart           # Keyframe, AnimatableProperty, EasingCurve
│   │   ├── transition.dart         # TransitionDefinition, CustomTransition
│   │   └── effect.dart             # EffectInstance, ShaderParam
│   ├── providers/                  # Riverpod state notifiers
│   │   ├── project_provider.dart
│   │   ├── timeline_provider.dart
│   │   ├── selection_provider.dart
│   │   └── playback_provider.dart
│   └── main.dart                   # Application bootstrap
└── test/                           # Unit & widget test suites
```

---

## 3. UI Screen Map

- **Home Dashboard**: Recents, New Project button, Quick Edit vs Studio Mode, Project management.
- **New Project Setup**: Project Name, Aspect Ratio (`16:9`, `9:16`, `1:1`, `4:5`, `3:4`, `4:3`), Frame Rate (`24`, `30`, `60`), Resolution (`720p`, `1080p`, `4K`).
- **Main Studio Workspace**:
  - Top Bar: Close (`✕`), Undo (`↶`), Redo (`↷`), Neon Green Export (`[ ↑ Export ]`).
  - Video Preview: 9:16 monitor, Ratio tag `[ 📱 9:16 ]`, Fullscreen `[ ⤢ ]`, Timecode `0:04.2 / 0:14.0`, Play circle `▶`, `1080p · 30fps`.
  - Multi-Track Timeline: Video filmstrip with thumbnails & `+` split add, Text pill `Sunday in Lisbon`, Audio waveform with purple background, Voiceover track `Tap to record voiceover`.
  - Contextual Bottom Bar: `Trim`, `Text`, `Audio`, `Filters`, `Effects`, `Speed`.
- **Radial Editing Menu**: Circular wheel with center action (`[ <> Trim ]`) and rotating tool group ring.
- **Auto Captions Studio**: Karaoke word highlighting (`we found this [ tiny ] bakery`), transcript timestamp editor, style presets (`Karaoke`, `Classic`, `BOLD`, `Mono`), color highlight palette.
- **Export Studio**: Quality presets, resolution/FPS sliders, download CTA.

