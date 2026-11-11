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

    final durationMs = math.max(editorState.project.durationMs, 5000.0);
    final currentTimeMs = editorState.currentTimeMs;
    final zoomScale = editorState.zoomScale;

    final pixelsPerMs = (basePixelsPerSecond * zoomScale) / 1000.0;
    final totalTimelineWidth = durationMs * pixelsPerMs;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final contentPaddingHorizontal = viewportWidth / 2;

        if (editorState.isPlaying) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncScrollWithPlayhead(currentTimeMs, zoomScale, viewportWidth);
          });
        }

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A0D14),
            border: Border(
              top: BorderSide(color: Video365Colors.cardBorder, width: 1),
            ),
          ),
          child: Stack(
            children: [
              // Scrollable Timeline Content
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

                        const SizedBox(height: 4),

                        // 2. FX / Adjustment Layer Track
                        _buildTrackRow(
                          trackId: 'track_effect',
                          trackType: TrackType.effect,
                          height: 32,
                          editorState: editorState,
                          editorNotifier: editorNotifier,
                          pixelsPerMs: pixelsPerMs,
                          emptyPlaceholder: 'No active effects',
                        ),

                        const SizedBox(height: 4),

                        // 3. Text / Motion Graphics Track
                        _buildTrackRow(
                          trackId: 'track_text',
                          trackType: TrackType.text,
                          height: 34,
                          editorState: editorState,
                          editorNotifier: editorNotifier,
                          pixelsPerMs: pixelsPerMs,
                          emptyPlaceholder: 'No titles or lower thirds',
                        ),

                        const SizedBox(height: 4),

                        // 4. Video & Media Track (V1)
                        _buildVideoFilmstripTrack(
                          editorState,
                          editorNotifier,
                          pixelsPerMs,
                        ),

                        const SizedBox(height: 4),

                        // 5. Audio Music Track (A1)
                        _buildAudioTrack(
                          editorState,
                          editorNotifier,
                          pixelsPerMs,
                        ),

                        const SizedBox(height: 4),

                        // 6. Voiceover Track (A2)
                        _buildVoiceoverTrack(editorState, pixelsPerMs),

                        const SizedBox(height: 8),
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

              // Left floating Track Labels
              Positioned(
                left: 10,
                top: 30,
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
      height: 22,
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

  Widget _buildTrackRow({
    required String trackId,
    required TrackType trackType,
    required double height,
    required EditorState editorState,
    required EditorNotifier editorNotifier,
    required double pixelsPerMs,
    required String emptyPlaceholder,
  }) {
    final track = editorState.project.tracks.firstWhere(
      (t) => t.id == trackId,
      orElse: () => TrackItem(id: trackId, type: trackType, name: ''),
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(6),
      ),
      child: track.clips.isEmpty
          ? Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                emptyPlaceholder,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : Stack(
              children: track.clips.map((clip) {
                final clipLeft = clip.startMs * pixelsPerMs;
                final clipWidth = clip.durationMs * pixelsPerMs;
                final isSelected = editorState.selectedClipId == clip.id;

                return Positioned(
                  left: clipLeft,
                  width: math.max(clipWidth, 40.0),
                  top: 2,
                  bottom: 2,
                  child: GestureDetector(
                    onTap: () => editorNotifier.selectClip(clip.id, trackId: track.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: clip.color.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: isSelected ? 1.8 : 0,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        clip.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
      orElse: () => const TrackItem(id: 'track_video', type: TrackType.video, name: 'Video'),
    );

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(6),
      ),
      child: videoTrack.clips.isEmpty
          ? Center(
              child: GestureDetector(
                onTap: () => notifier.toggleMediaBrowser(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: Video365Colors.activeGreen),
                    SizedBox(width: 6),
                    Text(
                      'Tap to Add Video, Photo, or GIF',
                      style: TextStyle(
                        color: Video365Colors.activeGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                ...videoTrack.clips.map((clip) {
                  final clipLeft = clip.startMs * pixelsPerMs;
                  final clipWidth = clip.durationMs * pixelsPerMs;
                  final isSelected = state.selectedClipId == clip.id;

                  return Positioned(
                    left: clipLeft,
                    width: math.max(clipWidth, 40.0),
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
                            color: isSelected ? Video365Colors.activeGreen : const Color(0xFF2A3448),
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
                            // Frame ticks
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
                                    child: Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Clip Title
                            Positioned(
                              top: 4,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.75),
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
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
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
      orElse: () => const TrackItem(id: 'track_audio', type: TrackType.audio, name: 'Audio'),
    );

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(6),
      ),
      child: audioTrack.clips.isEmpty
          ? Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: const Text(
                'No audio added',
                style: TextStyle(color: Color(0xFF334155), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            )
          : Stack(
              children: audioTrack.clips.map((clip) {
                final clipLeft = clip.startMs * pixelsPerMs;
                final clipWidth = clip.durationMs * pixelsPerMs;
                final isSelected = state.selectedClipId == clip.id;

                return Positioned(
                  left: clipLeft,
                  width: math.max(clipWidth, 40.0),
                  top: 2,
                  bottom: 2,
                  child: GestureDetector(
                    onTap: () => notifier.selectClip(clip.id, trackId: audioTrack.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF312E81).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected ? Video365Colors.activeGreen : const Color(0xFF4F46E5),
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
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.mic_none_rounded, size: 14, color: Video365Colors.secondaryText),
          SizedBox(width: 8),
          Text(
            'Tap to record voiceover',
            style: TextStyle(
              color: Video365Colors.secondaryText,
              fontSize: 10,
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
          _TrackLabelPill(icon: Icons.auto_fix_high_rounded, label: 'FX'),
          SizedBox(height: 18),
          _TrackLabelPill(icon: Icons.title_rounded, label: 'Text'),
          SizedBox(height: 18),
          _TrackLabelPill(icon: Icons.video_collection_outlined, label: 'Video'),
          SizedBox(height: 24),
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

    for (int s = 0; s <= totalSeconds; s++) {
      final x = s * pixelsPerSecond;
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
          Offset(x - (textPainter.width / 2), size.height - 20),
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
