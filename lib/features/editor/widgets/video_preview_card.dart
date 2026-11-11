import 'dart:io';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

    // Find active video clip
    final videoTrack = editorState.project.tracks.firstWhere(
      (t) => t.type == TrackType.video,
      orElse: () => const TrackItem(id: '', type: TrackType.video, name: ''),
    );

    final activeVideoClip = videoTrack.clips.firstWhere(
      (c) => currentTime >= c.startMs && currentTime <= c.endMs,
      orElse: () => videoTrack.clips.isNotEmpty
          ? videoTrack.clips.first
          : const ClipItem(id: '', trackId: '', type: TrackType.video, title: '', startMs: 0, durationMs: 0),
    );

    // Sync player source if clip exists
    if (activeVideoClip.id.isNotEmpty) {
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

    // Find active motion graphics / text clip
    final textTrack = editorState.project.tracks.firstWhere(
      (t) => t.type == TrackType.text,
      orElse: () => const TrackItem(id: '', type: TrackType.text, name: ''),
    );
    final activeTextClip = textTrack.clips.firstWhere(
      (c) => currentTime >= c.startMs && currentTime <= c.endMs,
      orElse: () => const ClipItem(id: '', trackId: '', type: TrackType.text, title: '', startMs: 0, durationMs: 0),
    );

    // Active color filter
    final filter = _getColorFilter(
      editorState.activeFilterPreset,
      editorState.activeFilterIntensity,
    );

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
                if (editorState.project.isEmpty || activeVideoClip.id.isEmpty) ...[
                  // CLEAN EMPTY STATE (No fake videos!)
                  _buildEmptyProjectCanvas(context, editorNotifier),
                ] else ...[
                  // ACTIVE VIDEO VIEWPORT
                  GestureDetector(
                    onTap: () => editorNotifier.togglePlay(),
                    behavior: HitTestBehavior.opaque,
                    child: filter != null
                        ? ColorFiltered(
                            colorFilter: filter,
                            child: _buildVideoSurface(activeVideoClip),
                          )
                        : _buildVideoSurface(activeVideoClip),
                  ),
                ],

                // 2. Motion Graphics & Lower Thirds Overlay (After Effects / JSX style)
                if (activeTextClip.id.isNotEmpty && activeTextClip.textContent != null)
                  _buildMotionGraphicsOverlay(activeTextClip),

                // 3. Bottom-Left Aspect Ratio Badge (NO EMOJIS!)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () => editorNotifier.cycleAspectRatio(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.crop_portrait_rounded,
                            size: 13,
                            color: Video365Colors.activeGreen,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            currentAspect.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Bottom-Right Fullscreen (NO EMOJIS!)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () => editorNotifier.toggleFullscreen(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        size: 16,
                        color: Colors.white,
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

  Widget _buildVideoSurface(ClipItem clip) {
    if (_isInitialized && _controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    if (clip.filePath != null &&
        (clip.filePath!.endsWith('.jpg') ||
            clip.filePath!.endsWith('.png') ||
            clip.filePath!.endsWith('.gif'))) {
      return Image.file(
        File(clip.filePath!),
        fit: BoxFit.cover,
      );
    }

    return Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Video365Colors.activeGreen.withOpacity(0.12),
                  border: Border.all(color: Video365Colors.activeGreen.withOpacity(0.4), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.video_call_outlined,
                  size: 32,
                  color: Video365Colors.activeGreen,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Start Your Project',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Import a video, photo, or GIF from your mobile device to begin editing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Video365Colors.secondaryText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Video365Colors.activeGreen,
                  foregroundColor: const Color(0xFF080A0E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text(
                  'Import Media',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                onPressed: () => notifier.toggleMediaBrowser(),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  final stock = MediaService.getBundledStockMedia().first;
                  notifier.addMediaClip(stock);
                },
                child: const Text(
                  'Or load sample 4K video',
                  style: TextStyle(color: Video365Colors.secondaryText, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotionGraphicsOverlay(ClipItem clip) {
    final type = clip.motionGraphicsType ?? 'lower_third_minimal';

    if (type == 'cyber_tag') {
      return Positioned(
        bottom: 60,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: clip.color, width: 2),
            boxShadow: [
              BoxShadow(color: clip.color.withOpacity(0.4), blurRadius: 12),
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
    }

    if (type == 'kinetic_punch') {
      return Center(
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
    }

    // Default: lower_third_minimal (clean accent vertical bar)
    return Positioned(
      bottom: 55,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
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
                      style: const TextStyle(
                        color: Video365Colors.secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
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
}
