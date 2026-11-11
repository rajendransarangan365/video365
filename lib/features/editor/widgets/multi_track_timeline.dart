import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';

class MultiTrackTimeline extends ConsumerStatefulWidget {
  const MultiTrackTimeline({super.key});

  @override
  ConsumerState<MultiTrackTimeline> createState() => _MultiTrackTimelineState();
}

class _MultiTrackTimelineState extends ConsumerState<MultiTrackTimeline> {
  final ScrollController _scrollController = ScrollController();
  bool _isUserScrolling = false;

  // Pixels per second at 1.0x zoom
  static const double basePixelsPerSecond = 80.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncScrollWithPlayhead(double currentTimeMs, double zoomScale, double viewportWidth) {
    if (_isUserScrolling || !_scrollController.hasClients) return;

    final pixelsPerMs = (basePixelsPerSecond * zoomScale) / 1000.0;
    final playheadX = currentTimeMs * pixelsPerMs;
    final targetScroll = playheadX - (viewportWidth / 2);

    if (targetScroll > 0 && targetScroll <= _scrollController.position.maxScrollExtent) {
      _scrollController.jumpTo(targetScroll);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    final durationMs = editorState.project.durationMs;
    final currentTimeMs = editorState.currentTimeMs;
    final zoomScale = editorState.zoomScale;

    final pixelsPerMs = (basePixelsPerSecond * zoomScale) / 1000.0;
    final totalTimelineWidth = durationMs * pixelsPerMs;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final contentPaddingHorizontal = viewportWidth / 2;

        // Auto-sync playhead if playing
        if (editorState.isPlaying) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncScrollWithPlayhead(currentTimeMs, zoomScale, viewportWidth);
          });
        }

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D1017),
            border: Border(
              top: BorderSide(color: Video365Colors.cardBorder, width: 1),
            ),
          ),
          child: Stack(
            children: [
              // Main scrollable timeline content
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _isUserScrolling = true;
                  } else if (notification is ScrollUpdateNotification) {
                    if (_isUserScrolling) {
                      final scrollOffset = _scrollController.offset;
                      final newTimeMs = (scrollOffset / pixelsPerMs).clamp(0.0, durationMs);
                      editorNotifier.seekTo(newTimeMs);
                    }
                  } else if (notification is ScrollEndNotification) {
                    _isUserScrolling = false;
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: contentPaddingHorizontal),
                    width: totalTimelineWidth + (contentPaddingHorizontal * 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Timecode Ruler with Ticks
                        _buildRuler(totalTimelineWidth, durationMs, zoomScale),

                        const SizedBox(height: 6),

                        // 2. Video Filmstrip Track (V1)
                        _buildVideoFilmstripTrack(
                          editorState,
                          editorNotifier,
                          pixelsPerMs,
                        ),

                        const SizedBox(height: 6),

                        // 3. Text Overlay Track (V2)
                        _buildTextTrack(
                          editorState,
                          editorNotifier,
                          pixelsPerMs,
                        ),

                        const SizedBox(height: 6),

                        // 4. Background Audio Track (A1)
                        _buildAudioTrack(
                          editorState,
                          editorNotifier,
                          pixelsPerMs,
                        ),

                        const SizedBox(height: 6),

                        // 5. Voiceover Track (A2)
                        _buildVoiceoverTrack(
                          editorState,
                          pixelsPerMs,
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed Center Playhead Needle
              Positioned(
                left: viewportWidth / 2,
                top: 0,
                bottom: 0,
                child: _buildPlayheadNeedle(currentTimeMs),
              ),

              // Left floating Track Labels / Mute toggles
              Positioned(
                left: 12,
                top: 36,
                child: _buildTrackLabels(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRuler(double width, double durationMs, double zoomScale) {
    return Container(
      height: 24,
      width: width,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF232A38), width: 0.8),
        ),
      ),
      child: CustomPaint(
        painter: TimelineRulerPainter(
          durationMs: durationMs,
          zoomScale: zoomScale,
          basePixelsPerSecond: basePixelsPerSecond,
        ),
      ),
    );
  }

  Widget _buildVideoFilmstripTrack(
    EditorState state,
    EditorNotifier notifier,
    double pixelsPerMs,
  ) {
    final videoTrack = state.project.tracks.firstWhere(
      (t) => t.type == TrackType.video,
      orElse: () => const TrackItem(id: '', type: TrackType.video, name: ''),
    );

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: videoTrack.clips.map((clip) {
          final clipLeft = clip.startMs * pixelsPerMs;
          final clipWidth = clip.durationMs * pixelsPerMs;
          final isSelected = state.selectedClipId == clip.id;

          return Positioned(
            left: clipLeft,
            width: clipWidth,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => notifier.selectClip(clip.id, trackId: videoTrack.id),
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2638),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Video365Colors.activeGreen
                        : const Color(0xFF2A3448),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Video365Colors.activeGreen.withOpacity(0.35),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Simulated Filmstrip Frames
                    Positioned.fill(
                      child: Row(
                        children: List.generate(
                          math.max(1, (clipWidth / 44).floor()),
                          (index) => Container(
                            width: 44,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.black.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Clip Title Badge
                    Positioned(
                      top: 4,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          clip.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Trim Handles if selected
                    if (isSelected) ...[
                      // Left Handle
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 10,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Video365Colors.activeGreen,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 2,
                            height: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Right Handle
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 10,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Video365Colors.activeGreen,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 2,
                            height: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextTrack(
    EditorState state,
    EditorNotifier notifier,
    double pixelsPerMs,
  ) {
    final textTrack = state.project.tracks.firstWhere(
      (t) => t.type == TrackType.text,
      orElse: () => const TrackItem(id: '', type: TrackType.text, name: ''),
    );

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: textTrack.clips.map((clip) {
          final clipLeft = clip.startMs * pixelsPerMs;
          final clipWidth = clip.durationMs * pixelsPerMs;
          final isSelected = state.selectedClipId == clip.id;

          return Positioned(
            left: clipLeft,
            width: clipWidth,
            top: 2,
            bottom: 2,
            child: GestureDetector(
              onTap: () => notifier.selectClip(clip.id, trackId: textTrack.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Video365Colors.activeGreen
                        : const Color(0xFF3B82F6),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.title_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        clip.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAudioTrack(
    EditorState state,
    EditorNotifier notifier,
    double pixelsPerMs,
  ) {
    final audioTrack = state.project.tracks.firstWhere(
      (t) => t.type == TrackType.audio,
      orElse: () => const TrackItem(id: '', type: TrackType.audio, name: ''),
    );

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: audioTrack.clips.map((clip) {
          final clipLeft = clip.startMs * pixelsPerMs;
          final clipWidth = clip.durationMs * pixelsPerMs;
          final isSelected = state.selectedClipId == clip.id;

          return Positioned(
            left: clipLeft,
            width: clipWidth,
            top: 2,
            bottom: 2,
            child: GestureDetector(
              onTap: () => notifier.selectClip(clip.id, trackId: audioTrack.id),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF312E81).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Video365Colors.activeGreen
                        : const Color(0xFF4F46E5),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(
                  painter: AudioWaveformPainter(
                    color: const Color(0xFF818CF8),
                    totalBars: math.max(10, (clipWidth / 4).floor()),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVoiceoverTrack(EditorState state, double pixelsPerMs) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF222938),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.mic_none_rounded, size: 14, color: Video365Colors.secondaryText),
          SizedBox(width: 8),
          Text(
            'Tap to record voiceover',
            style: TextStyle(
              color: Video365Colors.secondaryText,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayheadNeedle(double currentTimeMs) {
    final totalSeconds = currentTimeMs / 1000.0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds.toInt() % 60;
    final pillText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return SizedBox(
      width: 44,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Needle Line
          Positioned(
            top: 20,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Top Pill Tag Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              pillText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackLabels() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Video365Colors.panelBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Video365Colors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _TrackLabelPill(icon: Icons.video_collection_outlined, label: 'Video'),
          SizedBox(height: 18),
          _TrackLabelPill(icon: Icons.title_rounded, label: 'Text'),
          SizedBox(height: 16),
          _TrackLabelPill(icon: Icons.music_note_rounded, label: 'Music'),
          SizedBox(height: 16),
          _TrackLabelPill(icon: Icons.mic_rounded, label: 'Voice'),
        ],
      ),
    );
  }
}

class _TrackLabelPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrackLabelPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Video365Colors.secondaryText),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Video365Colors.secondaryText,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TimelineRulerPainter extends CustomPainter {
  final double durationMs;
  final double zoomScale;
  final double basePixelsPerSecond;

  TimelineRulerPainter({
    required this.durationMs,
    required this.zoomScale,
    required this.basePixelsPerSecond,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.2;

    final textStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 9,
      fontWeight: FontWeight.w600,
      fontFamily: 'monospace',
    );

    final totalSeconds = (durationMs / 1000.0).ceil();
    final pixelsPerSecond = basePixelsPerSecond * zoomScale;

    // Draw second ticks
    for (int s = 0; s <= totalSeconds; s++) {
      final x = s * pixelsPerSecond;

      // Major tick every 4 seconds or 2 seconds based on zoom
      final isMajor = s % 4 == 0;

      if (isMajor) {
        canvas.drawLine(
          Offset(x, size.height - 10),
          Offset(x, size.height),
          majorTickPaint,
        );

        final minutes = s ~/ 60;
        final seconds = s % 60;
        final label = '$minutes:${seconds.toString().padLeft(2, '0')}';

        final textSpan = TextSpan(text: label, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(x - (textPainter.width / 2), size.height - 22),
        );
      } else {
        canvas.drawLine(
          Offset(x, size.height - 5),
          Offset(x, size.height),
          tickPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimelineRulerPainter oldDelegate) {
    return oldDelegate.durationMs != durationMs ||
        oldDelegate.zoomScale != zoomScale;
  }
}

class AudioWaveformPainter extends CustomPainter {
  final Color color;
  final int totalBars;

  AudioWaveformPainter({required this.color, required this.totalBars});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final step = size.width / totalBars;

    // Deterministic procedural waveform pattern
    for (int i = 0; i < totalBars; i++) {
      final x = i * step + (step / 2);
      final heightRatio = (math.sin(i * 0.4) * 0.4 + math.cos(i * 0.9) * 0.35).abs() + 0.15;
      final barHeight = (size.height * 0.75) * heightRatio;

      canvas.drawLine(
        Offset(x, centerY - (barHeight / 2)),
        Offset(x, centerY + (barHeight / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) => false;
}
