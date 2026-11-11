import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../core/widgets/video365_icons.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';

class VideoPreviewCard extends ConsumerStatefulWidget {
  const VideoPreviewCard({super.key});

  @override
  ConsumerState<VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends ConsumerState<VideoPreviewCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.asset('assets/samples/sample_video365.mp4');
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video initialization note: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    // Sync video player with editor play/pause state
    if (_isInitialized && _controller != null) {
      if (editorState.isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!editorState.isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }

    final currentAspect = editorState.project.aspectRatio;
    final currentTime = editorState.currentTimeMs;

    // Find active subtitle
    final activeSubtitle = editorState.project.subtitles.firstWhere(
      (s) => currentTime >= s.startMs && currentTime <= s.endMs,
      orElse: () => const SubtitleItem(id: '', startMs: 0, endMs: 0, text: ''),
    );

    // Find active text overlay clip
    final textTrack = editorState.project.tracks.firstWhere(
      (t) => t.type == TrackType.text,
      orElse: () => const TrackItem(id: '', type: TrackType.text, name: ''),
    );
    final activeTextClip = textTrack.clips.firstWhere(
      (c) => currentTime >= c.startMs && currentTime <= c.endMs,
      orElse: () => const ClipItem(
        id: '',
        trackId: '',
        type: TrackType.text,
        title: '',
        startMs: 0,
        durationMs: 0,
      ),
    );

    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: currentAspect.ratio,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF11151D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Video365Colors.cardBorder, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Video or Stylized Placeholder
                GestureDetector(
                  onTap: () => editorNotifier.togglePlay(),
                  behavior: HitTestBehavior.opaque,
                  child: _isInitialized && _controller != null
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Atmospheric forest river aesthetic from screenshot
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: LisbonLandscapePainter(),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                // 2. Text Overlay Layer ("Sunday in Lisbon")
                if (activeTextClip.id.isNotEmpty && activeTextClip.textContent != null)
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: Text(
                      activeTextClip.textContent!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 3. Subtitle / Karaoke Highlighting Overlay
                if (activeSubtitle.id.isNotEmpty)
                  Positioned(
                    bottom: 70,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: activeSubtitle.words.map((w) {
                          final isWordActive =
                              currentTime >= w.startMs && currentTime <= w.endMs;
                          return Container(
                            padding: isWordActive
                                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                                : const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                            decoration: BoxDecoration(
                              color: isWordActive
                                  ? editorState.captionHighlightColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              w.word,
                              style: TextStyle(
                                color: isWordActive
                                    ? Colors.black
                                    : Video365Colors.primaryText,
                                fontSize: 16,
                                fontWeight:
                                    isWordActive ? FontWeight.w800 : FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                // 4. Bottom-Left Aspect Ratio Pill [ 📱 9:16 ]
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () => editorNotifier.cycleAspectRatio(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Video365Icon(
                            Video365IconType.aspectRatio,
                            size: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            currentAspect.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. Bottom-Right Fullscreen [ ⤢ ]
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () => editorNotifier.toggleFullscreen(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: const Video365Icon(
                        Video365IconType.fullscreen,
                        size: 13,
                        color: Colors.white70,
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
}

/// Fallback scenic landscape painter evoking "Sunday in Lisbon" nature scene
class LisbonLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Misty mountain ridges
    final ridgePaint1 = Paint()..color = const Color(0xFF1E2638).withOpacity(0.8);
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.3, size.width * 0.6, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.35, size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, ridgePaint1);

    // Forest tree silhouettes on both sides
    final forestPaint = Paint()..color = const Color(0xFF0F1C1B);
    final leftTrees = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.4, size.height * 0.6)
      ..lineTo(size.width * 0.3, size.height * 0.8)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(leftTrees, forestPaint);

    final rightTrees = Path()
      ..moveTo(size.width, size.height * 0.35)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.7, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(rightTrees, forestPaint);

    // River in the center winding through the valley
    final riverPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFFE2E8F0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5));

    final river = Path()
      ..moveTo(size.width * 0.48, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.52, size.height * 0.65, size.width * 0.45, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.9, size.width * 0.5, size.height)
      ..lineTo(size.width * 0.58, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width * 0.55, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.65, size.width * 0.52, size.height * 0.5)
      ..close();
    canvas.drawPath(river, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
