import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';
import '../../../services/media_service.dart';

class VideoPreviewCard extends ConsumerStatefulWidget {
  const VideoPreviewCard({super.key});

  @override
  ConsumerState<VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends ConsumerState<VideoPreviewCard> {
  VideoPlayerController? _controller;
  String? _currentLoadedSource;
  bool _isInitialized = false;

  VideoPlayerController? _audioController;
  String? _currentAudioSource;
  bool _isAudioInitialized = false;

  @override
  void dispose() {
    _controller?.dispose();
    _audioController?.dispose();
    super.dispose();
  }

  Future<void> _updateAudioPlayerSource(ClipItem? clip) async {
    if (clip == null) {
      if (_audioController != null) {
        await _audioController!.pause();
        await _audioController!.dispose();
        _audioController = null;
        _currentAudioSource = null;
        if (mounted) setState(() => _isAudioInitialized = false);
      }
      return;
    }

    final targetSource = clip.filePath ?? clip.assetPath ?? '';
    if (targetSource.isEmpty) return;
    if (targetSource == _currentAudioSource && _audioController != null) return;

    try {
      await _audioController?.dispose();
      _audioController = null;

      if (clip.filePath != null) {
        _audioController = VideoPlayerController.file(File(clip.filePath!));
      } else if (clip.assetPath != null) {
        _audioController = VideoPlayerController.asset(clip.assetPath!);
      }

      if (_audioController != null) {
        await _audioController!.initialize();
        _audioController!.setLooping(false);
        _currentAudioSource = targetSource;
        if (mounted) setState(() => _isAudioInitialized = true);
      }
    } catch (e) {
      debugPrint('VideoPreviewCard audio controller error: $e');
    }
  }

  Future<void> _updatePlayerSource(ClipItem? clip) async {
    if (clip == null) {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
        _currentLoadedSource = null;
        if (mounted) setState(() => _isInitialized = false);
      }
      return;
    }

    final targetSource = clip.filePath ?? clip.assetPath ?? '';
    if (targetSource.isEmpty || targetSource == _currentLoadedSource) return;

    try {
      await _controller?.dispose();
      _controller = null;

      if (clip.filePath != null) {
        _controller = VideoPlayerController.file(File(clip.filePath!));
      } else if (clip.assetPath != null) {
        _controller = VideoPlayerController.asset(clip.assetPath!);
      }

      if (_controller != null) {
        await _controller!.initialize();
        _controller!.setLooping(true);
        _currentLoadedSource = targetSource;
        if (mounted) setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('VideoPreviewCard controller error: $e');
    }
  }

  ColorFilter? _getColorFilter(String? preset, double intensity) {
    if (preset == null || preset == 'none') return null;

    switch (preset) {
      case 'teal_orange':
        return const ColorFilter.matrix([
          1.15, 0.00, 0.00, 0.0, 10,
          0.00, 0.95, 0.00, 0.0, 5,
          0.00, 0.00, 1.25, 0.0, 15,
          0.00, 0.00, 0.00, 1.0, 0,
        ]);
      case 'moody_dark':
        return const ColorFilter.matrix([
          0.90, 0.00, 0.00, 0.0, -10,
          0.00, 0.90, 0.00, 0.0, -10,
          0.00, 0.00, 0.95, 0.0, -5,
          0.00, 0.00, 0.00, 1.0, 0,
        ]);
      case 'cyberpunk':
        return const ColorFilter.matrix([
          1.25, 0.00, 0.20, 0.0, 10,
          0.00, 0.80, 0.00, 0.0, -5,
          0.10, 0.00, 1.35, 0.0, 15,
          0.00, 0.00, 0.00, 1.0, 0,
        ]);
      case 'golden_hour':
        return const ColorFilter.matrix([
          1.20, 0.00, 0.00, 0.0, 15,
          0.05, 1.10, 0.00, 0.0, 10,
          0.00, 0.00, 0.80, 0.0, -10,
          0.00, 0.00, 0.00, 1.0, 0,
        ]);
      case 'noir':
        return const ColorFilter.matrix([
          0.33, 0.33, 0.33, 0.0, 0,
          0.33, 0.33, 0.33, 0.0, 0,
          0.33, 0.33, 0.33, 0.0, 0,
          0.00, 0.00, 0.00, 1.0, 0,
        ]);
      case 'vintage':
        return const ColorFilter.matrix([
          0.90, 0.10, 0.05, 0.0, 10,
          0.05, 0.90, 0.05, 0.0, 5,
          0.05, 0.05, 0.75, 0.0, -10,
          0.00, 0.00, 0.00, 1.0, 0,
        ]);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final currentAspect = editorState.project.aspectRatio;
    final currentTime = editorState.currentTimeMs;

    // Find active video/image clip across all visible tracks at currentTime
    ClipItem? activeVideoClip;
    for (final track in editorState.project.tracks) {
      if (track.isHidden) continue;
      if (track.type == TrackType.video || track.type == TrackType.image) {
        for (final clip in track.clips) {
          if (currentTime >= clip.startMs && currentTime <= clip.endMs) {
            activeVideoClip = clip;
            break;
          }
        }
        if (activeVideoClip != null) break;
      }
    }

    // Fallback: if no clip is exactly at playhead, use first available video/image clip
    if (activeVideoClip == null) {
      for (final track in editorState.project.tracks) {
        if (!track.isHidden && (track.type == TrackType.video || track.type == TrackType.image)) {
          if (track.clips.isNotEmpty) {
            activeVideoClip = track.clips.first;
            break;
          }
        }
      }
    }

    // Sync player source if clip exists
    if (activeVideoClip != null && activeVideoClip.id.isNotEmpty) {
      _updatePlayerSource(activeVideoClip);
    } else {
      _updatePlayerSource(null);
    }

    // Sync playback state
    if (_isInitialized && _controller != null) {
      if (editorState.isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!editorState.isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }

    // Find active audio clip across all unmuted audio & voiceover tracks
    ClipItem? activeAudioClip;
    for (final track in editorState.project.tracks) {
      if (track.isHidden || track.isMuted) continue;
      if (track.type == TrackType.audio || track.type == TrackType.voiceover) {
        for (final clip in track.clips) {
          if (currentTime >= clip.startMs && currentTime <= clip.endMs) {
            activeAudioClip = clip;
            break;
          }
        }
        if (activeAudioClip != null) break;
      }
    }

    // Sync audio player source
    if (activeAudioClip != null && activeAudioClip.id.isNotEmpty) {
      _updateAudioPlayerSource(activeAudioClip);
    } else {
      _updateAudioPlayerSource(null);
    }

    // Sync audio playback state & volume
    if (_isAudioInitialized && _audioController != null && activeAudioClip != null) {
      final targetVolume = editorState.isAudioMuted ? 0.0 : activeAudioClip.volume;
      _audioController!.setVolume(targetVolume);

      if (editorState.isPlaying && !_audioController!.value.isPlaying) {
        final seekPosMs = (currentTime - activeAudioClip.startMs + activeAudioClip.sourceInMs).clamp(0.0, activeAudioClip.durationMs);
        _audioController!.seekTo(Duration(milliseconds: seekPosMs.toInt()));
        _audioController!.play();
      } else if (!editorState.isPlaying && _audioController!.value.isPlaying) {
        _audioController!.pause();
      }
    }

    // Find active motion graphics / text clip across all text tracks
    ClipItem? activeTextClip;
    for (final track in editorState.project.tracks) {
      if (track.isHidden) continue;
      if (track.type == TrackType.text) {
        for (final clip in track.clips) {
          if (currentTime >= clip.startMs && currentTime <= clip.endMs) {
            activeTextClip = clip;
            break;
          }
        }
        if (activeTextClip != null) break;
      }
    }

    // Active color filter
    final filter = _getColorFilter(
      editorState.activeFilterPreset,
      editorState.activeFilterIntensity,
    );

    // Find active transition at currentTimeMs
    ClipTransition? activeTransition;
    ClipItem? transitionLeftClip;
    ClipItem? transitionRightClip;
    double transitionProgress = 0.0;

    for (final tr in editorState.project.transitions) {
      if (tr.type == TransitionType.none) continue;
      ClipItem? cL;
      ClipItem? cR;
      for (final t in editorState.project.tracks) {
        for (final c in t.clips) {
          if (c.id == tr.leftClipId) cL = c;
          if (c.id == tr.rightClipId) cR = c;
        }
      }
      if (cL != null && cR != null) {
        final cutTime = cR.startMs;
        final halfDur = tr.durationMs / 2.0;
        final tStart = cutTime - halfDur;
        final tEnd = cutTime + halfDur;
        if (currentTime >= tStart && currentTime <= tEnd) {
          activeTransition = tr;
          transitionLeftClip = cL;
          transitionRightClip = cR;
          transitionProgress = ((currentTime - tStart) / (tEnd - tStart)).clamp(0.0, 1.0);
          break;
        }
      }
    }

    // Find active effect clip on any FX track
    ClipItem? activeFxClip;
    for (final track in editorState.project.tracks) {
      if (track.isHidden) continue;
      if (track.type == TrackType.effect) {
        for (final clip in track.clips) {
          if (currentTime >= clip.startMs && currentTime <= clip.endMs) {
            activeFxClip = clip;
            break;
          }
        }
        if (activeFxClip != null) break;
      }
    }

    final activeEffectType = activeFxClip?.effectType ?? activeVideoClip?.effectType ?? editorState.activeEffectType;
    final activeEffectIntensity = activeFxClip?.effectIntensity ?? activeVideoClip?.effectIntensity ?? editorState.activeEffectIntensity;

    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: currentAspect.ratio,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Video365Colors.cardBorder, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Content: Empty Canvas OR Active Video Player
                if (editorState.project.isEmpty || activeVideoClip == null || activeVideoClip.id.isEmpty) ...[
                  // CLEAN EMPTY STATE (No fake videos!)
                  _buildEmptyProjectCanvas(context, editorNotifier),
                ] else ...[
                  // ACTIVE VIDEO VIEWPORT (Touch Gestures: Drag to Move, Pinch to Scale, Double-Tap Play/Pause)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => editorNotifier.togglePlay(),
                    onDoubleTap: () => editorNotifier.togglePlay(),
                    onScaleUpdate: (details) {
                      if (activeVideoClip != null && activeVideoClip.id.isNotEmpty) {
                        if (details.pointerCount == 1) {
                          editorNotifier.updateClipPosition(activeVideoClip.id, details.focalPointDelta);
                        } else if (details.pointerCount > 1 && details.scale != 1.0) {
                          editorNotifier.updateClipScale(activeVideoClip.id, details.scale);
                        }
                      }
                    },
                    child: _applyEffectShaders(
                      (activeTransition != null && transitionLeftClip != null && transitionRightClip != null)
                          ? _buildTransitionSurface(
                              activeTransition,
                              transitionLeftClip!,
                              transitionRightClip!,
                              transitionProgress,
                              currentTime,
                            )
                          : _buildVideoSurface(activeVideoClip, currentTime),
                      activeEffectType,
                      activeEffectIntensity,
                      currentTime,
                      filter,
                    ),
                  ),
                ],

                // 2. Motion Graphics & Lower Thirds Overlay (After Effects / JSX style)
                if (activeTextClip != null && activeTextClip.id.isNotEmpty && activeTextClip.textContent != null)
                  _buildMotionGraphicsOverlay(activeTextClip),

                // 3. Floating Playback Controls Bar (Matching Reference Image 1 & 5)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Audio Volume Toggle
                        GestureDetector(
                          onTap: () {
                            editorNotifier.toggleMute();
                            HapticFeedback.selectionClick();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: editorState.isAudioMuted
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              editorState.isAudioMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              size: 18,
                              color: editorState.isAudioMuted
                                  ? const Color(0xFFEF4444)
                                  : Colors.white,
                            ),
                          ),
                        ),

                        // Center: Primary Play / Pause Button with Emerald Glow
                        GestureDetector(
                          onTap: () {
                            editorNotifier.togglePlay();
                            HapticFeedback.lightImpact();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: editorState.isPlaying
                                  ? const LinearGradient(
                                      colors: [Color(0xFF20C878), Color(0xFF10B981)],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0.1),
                                      ],
                                    ),
                              border: Border.all(
                                color: editorState.isPlaying
                                    ? Video365Colors.activeGreen
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: editorState.isPlaying
                                  ? [
                                      BoxShadow(
                                        color: Video365Colors.activeGreen.withValues(alpha: 0.45),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              editorState.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 22,
                              color: editorState.isPlaying
                                  ? const Color(0xFF080A0E)
                                  : Colors.white,
                            ),
                          ),
                        ),

                        // Right: Fullscreen / Aspect Ratio Toggle
                        GestureDetector(
                          onTap: () {
                            editorNotifier.cycleAspectRatio();
                            HapticFeedback.selectionClick();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Top-Left Aspect Ratio Indicator Badge
                Positioned(
                  left: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () => editorNotifier.cycleAspectRatio(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.crop_portrait_rounded,
                            size: 11,
                            color: Video365Colors.activeGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentAspect.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSurface(ClipItem clip, double currentTimeMs) {
    Widget surface;
    if (_isInitialized && _controller != null) {
      surface = FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    } else if (clip.bytes != null) {
      surface = Image.memory(
        clip.bytes!,
        fit: BoxFit.cover,
      );
    } else if (clip.filePath != null &&
        (clip.filePath!.endsWith('.jpg') ||
            clip.filePath!.endsWith('.png') ||
            clip.filePath!.endsWith('.gif') ||
            clip.filePath!.endsWith('.jpeg') ||
            clip.filePath!.endsWith('.webp'))) {
      surface = Image.file(
        File(clip.filePath!),
        fit: BoxFit.cover,
      );
    } else {
      surface = Container(
        color: const Color(0xFF131722),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.movie_creation_outlined, size: 36, color: Video365Colors.activeGreen),
              const SizedBox(height: 6),
              Text(
                clip.title,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final relMs = (currentTimeMs - clip.startMs).clamp(0.0, clip.durationMs);
    final dynScale = clip.evaluateProperty(KeyframeProperty.scale, relMs, clip.scale);
    final dynOpacity = clip.evaluateProperty(KeyframeProperty.opacity, relMs, clip.opacity).clamp(0.0, 1.0);
    final dynRot = clip.evaluateProperty(KeyframeProperty.rotation, relMs, clip.rotation);
    final dynPosX = clip.evaluateProperty(KeyframeProperty.positionX, relMs, clip.position.dx);
    final dynPosY = clip.evaluateProperty(KeyframeProperty.positionY, relMs, clip.position.dy);

    return Transform.translate(
      offset: Offset(dynPosX, dynPosY),
      child: Transform.rotate(
        angle: dynRot * (math.pi / 180),
        child: Transform.scale(
          scale: dynScale,
          child: Opacity(
            opacity: dynOpacity,
            child: surface,
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionSurface(
    ClipTransition tr,
    ClipItem leftClip,
    ClipItem rightClip,
    double progress,
    double currentTime,
  ) {
    final leftWidget = _buildVideoSurface(leftClip, currentTime);
    final rightWidget = _buildVideoSurface(rightClip, currentTime);

    switch (tr.type) {
      case TransitionType.crossDissolve:
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: (1.0 - progress).clamp(0.0, 1.0),
              child: leftWidget,
            ),
            Opacity(
              opacity: progress.clamp(0.0, 1.0),
              child: rightWidget,
            ),
          ],
        );

      case TransitionType.fadeToBlack:
        if (progress < 0.5) {
          final factor = (1.0 - progress * 2.0).clamp(0.0, 1.0);
          return ColoredBox(
            color: Colors.black,
            child: Opacity(opacity: factor, child: leftWidget),
          );
        } else {
          final factor = ((progress - 0.5) * 2.0).clamp(0.0, 1.0);
          return ColoredBox(
            color: Colors.black,
            child: Opacity(opacity: factor, child: rightWidget),
          );
        }

      case TransitionType.wipeLeft:
        return Stack(
          fit: StackFit.expand,
          children: [
            leftWidget,
            ClipPath(
              clipper: _WipeHorizontalClipper(progress: progress, fromRight: true),
              child: rightWidget,
            ),
          ],
        );

      case TransitionType.wipeRight:
        return Stack(
          fit: StackFit.expand,
          children: [
            leftWidget,
            ClipPath(
              clipper: _WipeHorizontalClipper(progress: progress, fromRight: false),
              child: rightWidget,
            ),
          ],
        );

      case TransitionType.zoomIn:
        final leftScale = 1.0 + 0.6 * progress;
        final rightScale = 0.5 + 0.5 * progress;
        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: leftScale,
              child: Opacity(
                opacity: (1.0 - progress).clamp(0.0, 1.0),
                child: leftWidget,
              ),
            ),
            Transform.scale(
              scale: rightScale,
              child: Opacity(
                opacity: progress.clamp(0.0, 1.0),
                child: rightWidget,
              ),
            ),
          ],
        );

      case TransitionType.glitch:
        final jitter = (math.sin(progress * 40.0) * 12.0 * (1.0 - (progress - 0.5).abs() * 2)).toDouble();
        final currentSurface = progress < 0.5 ? leftWidget : rightWidget;
        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(jitter, 0),
              child: currentSurface,
            ),
            CustomPaint(
              foregroundPainter: _GlitchStripePainter(
                intensity: (1.0 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0),
                seed: progress * 100,
              ),
            ),
          ],
        );

      case TransitionType.none:
      default:
        return progress < 0.5 ? leftWidget : rightWidget;
    }
  }

  Widget _applyEffectShaders(
    Widget child,
    String? effectType,
    double intensity,
    double currentTime,
    ColorFilter? filter,
  ) {
    Widget result = child;
    if (filter != null) {
      result = ColorFiltered(colorFilter: filter, child: result);
    }

    if (effectType == null || effectType == 'none' || intensity <= 0) {
      return result;
    }

    switch (effectType) {
      case 'retro_shake':
        final dx = math.sin(currentTime * 0.035) * 8.0 * intensity;
        final dy = math.cos(currentTime * 0.028) * 6.0 * intensity;
        final rot = math.sin(currentTime * 0.02) * 0.03 * intensity;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rot,
            child: result,
          ),
        );

      case 'rgb_glitch':
        final jitterX = math.sin(currentTime * 0.04) * 6.0 * intensity;
        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(jitterX, 0),
              child: result,
            ),
            CustomPaint(
              foregroundPainter: _GlitchStripePainter(
                intensity: intensity,
                seed: currentTime,
              ),
            ),
          ],
        );

      case 'diamond_blur':
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: 8.0 * intensity,
            sigmaY: 8.0 * intensity,
          ),
          child: result,
        );

      case 'film_grain':
        return Stack(
          fit: StackFit.expand,
          children: [
            result,
            CustomPaint(
              foregroundPainter: _FilmGrainPainter(
                intensity: intensity,
                seed: currentTime,
              ),
            ),
          ],
        );

      case 'vhs_1984':
        return Stack(
          fit: StackFit.expand,
          children: [
            result,
            CustomPaint(
              foregroundPainter: _VhsScanlinePainter(
                intensity: intensity,
                time: currentTime,
              ),
            ),
          ],
        );

      case 'edge_glow':
        return Stack(
          fit: StackFit.expand,
          children: [
            result,
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.6 * intensity),
                    width: 6.0 * intensity,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.5 * intensity),
                      blurRadius: 20 * intensity,
                      spreadRadius: 2 * intensity,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      default:
        return result;
    }
  }

  Widget _buildEmptyProjectCanvas(BuildContext context, EditorNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E121A),
        border: Border.all(
          color: const Color(0xFF232A38),
          width: 1.5,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Video365Colors.activeGreen.withValues(alpha: 0.12),
                  border: Border.all(color: Video365Colors.activeGreen.withValues(alpha: 0.4), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.video_call_outlined,
                  size: 24,
                  color: Video365Colors.activeGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start Your Project',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Import a video, photo, or GIF to begin editing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Video365Colors.secondaryText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Video365Colors.activeGreen,
                  foregroundColor: const Color(0xFF080A0E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                label: const Text(
                  'Import Media',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                onPressed: () => notifier.toggleMediaBrowser(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotionGraphicsOverlay(ClipItem clip) {
    final type = clip.motionGraphicsType ?? 'lower_third_minimal';
    Widget overlay;

    if (type == 'cyber_tag') {
      overlay = Positioned(
        bottom: 60,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: clip.color, width: 2),
            boxShadow: [
              BoxShadow(color: clip.color.withValues(alpha: 0.4), blurRadius: 12),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                clip.textContent ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: clip.fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              if (clip.subtitleContent != null && clip.subtitleContent!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  clip.subtitleContent!,
                  style: TextStyle(
                    color: clip.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else if (type == 'kinetic_punch') {
      overlay = Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: clip.color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            (clip.textContent ?? '').toUpperCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
    } else {
      // Default: lower_third_minimal (clean accent vertical bar)
      overlay = Positioned(
        bottom: 55,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: clip.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      clip.textContent ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: clip.fontSize * 0.75,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (clip.subtitleContent != null && clip.subtitleContent!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        clip.subtitleContent!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Transform.translate(
      offset: clip.position,
      child: Transform.scale(
        scale: clip.scale,
        child: overlay,
      ),
    );
  }
}

class _WipeHorizontalClipper extends CustomClipper<Path> {
  final double progress;
  final bool fromRight;

  _WipeHorizontalClipper({required this.progress, required this.fromRight});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (fromRight) {
      final left = size.width * (1.0 - progress);
      path.addRect(Rect.fromLTRB(left, 0, size.width, size.height));
    } else {
      final right = size.width * progress;
      path.addRect(Rect.fromLTRB(0, 0, right, size.height));
    }
    return path;
  }

  @override
  bool shouldReclip(_WipeHorizontalClipper oldClipper) =>
      oldClipper.progress != progress || oldClipper.fromRight != fromRight;
}

class _GlitchStripePainter extends CustomPainter {
  final double intensity;
  final double seed;

  _GlitchStripePainter({required this.intensity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final rand = math.Random(seed.toInt() ^ 0x5F3759DF);
    final count = (6 * intensity).toInt() + 2;

    for (int i = 0; i < count; i++) {
      final y = rand.nextDouble() * size.height;
      final h = rand.nextDouble() * 12.0 * intensity + 2.0;
      final offset = (rand.nextDouble() - 0.5) * 30.0 * intensity;
      final isCyan = rand.nextBool();

      final paint = Paint()
        ..color = (isCyan ? const Color(0xFF00E5FF) : const Color(0xFFFF0055))
            .withValues(alpha: (0.35 * intensity).clamp(0.0, 1.0))
        ..blendMode = BlendMode.screen;

      canvas.drawRect(Rect.fromLTWH(offset, y, size.width, h), paint);
    }
  }

  @override
  bool shouldRepaint(_GlitchStripePainter old) => old.seed != seed || old.intensity != intensity;
}

class _FilmGrainPainter extends CustomPainter {
  final double intensity;
  final double seed;

  _FilmGrainPainter({required this.intensity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final rand = math.Random((seed * 10).toInt() ^ 0x1234567);
    final dotCount = (size.width * size.height / 350 * intensity).toInt().clamp(50, 1200);

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: (0.18 * intensity).clamp(0.0, 0.5))
      ..strokeWidth = 1.2
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dotCount; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(_FilmGrainPainter old) => old.seed != seed || old.intensity != intensity;
}

class _VhsScanlinePainter extends CustomPainter {
  final double intensity;
  final double time;

  _VhsScanlinePainter({required this.intensity, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final scanlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: (0.25 * intensity).clamp(0.0, 0.6))
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }

    final barY = (time * 0.15) % size.height;
    final barPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.2 * intensity).clamp(0.0, 0.4))
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(0, barY, size.width, 14 * intensity), barPaint);
  }

  @override
  bool shouldRepaint(_VhsScanlinePainter old) => old.time != time || old.intensity != intensity;
}
