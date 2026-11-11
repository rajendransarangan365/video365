import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';
import 'clip_property_panel.dart';

// ─── Constants ────────────────────────────────────────────────────────────────
const double _kTrackHeaderWidth = 58.0;
const double _kTrackHeight = 44.0;
const double _kAudioTrackHeight = 38.0;
const double _kSmallTrackHeight = 36.0;
const double _kRulerHeight = 22.0;
const double _kBasePixelsPerSecond = 60.0;

// ─── Main Timeline Widget ─────────────────────────────────────────────────────
class MultiTrackTimeline extends ConsumerStatefulWidget {
  const MultiTrackTimeline({super.key});

  @override
  ConsumerState<MultiTrackTimeline> createState() => _MultiTrackTimelineState();
}

class _MultiTrackTimelineState extends ConsumerState<MultiTrackTimeline> {
  final ScrollController _hScroll = ScrollController();
  final ScrollController _vScroll = ScrollController();
  final ScrollController _headerVScroll = ScrollController();
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();
    _vScroll.addListener(_syncVerticalScroll);
  }

  void _syncVerticalScroll() {
    if (_vScroll.hasClients && _headerVScroll.hasClients) {
      if (_headerVScroll.offset != _vScroll.offset) {
        _headerVScroll.jumpTo(_vScroll.offset.clamp(0.0, _headerVScroll.position.maxScrollExtent));
      }
    }
  }

  @override
  void dispose() {
    _vScroll.removeListener(_syncVerticalScroll);
    _hScroll.dispose();
    _vScroll.dispose();
    _headerVScroll.dispose();
    super.dispose();
  }

  double get _pixelsPerMs =>
      (_kBasePixelsPerSecond * (ref.read(editorProvider).zoomScale)) / 1000.0;

  void _onTimelineTap(TapUpDetails details, double viewportWidth) {
    final ed = ref.read(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    if (!_hScroll.hasClients) return;
    final localX = details.localPosition.dx;
    final localY = details.localPosition.dy;
    final timeMs = (localX / _pixelsPerMs).clamp(0.0, ed.project.durationMs);

    // Seek to tapped position
    notifier.seekTo(timeMs);

    // Hit test tracks and clips
    double currentY = _kRulerHeight;
    String? hitClipId;
    String? hitTrackId;

    for (final track in ed.project.tracks) {
      final tHeight = _trackHeight(track.type) + 2.0; // including margin
      if (localY >= currentY && localY <= currentY + tHeight) {
        hitTrackId = track.id;
        for (final clip in track.clips) {
          if (timeMs >= clip.startMs && timeMs <= clip.endMs) {
            hitClipId = clip.id;
            break;
          }
        }
        break;
      }
      currentY += tHeight;
    }

    if (hitClipId != null) {
      notifier.selectClip(hitClipId, trackId: hitTrackId);
    } else if (localY > _kRulerHeight) {
      // Tapped empty track area
      notifier.selectClip(null, trackId: hitTrackId);
    }
  }

  double _baseZoomScale = 1.0;

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoomScale = ref.read(editorProvider).zoomScale;
    if (details.pointerCount == 1) {
      _isScrubbing = true;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final notifier = ref.read(editorProvider.notifier);
    final ed = ref.read(editorProvider);

    if (details.pointerCount > 1) {
      // Two-finger pinch to zoom in/out!
      final newScale = (_baseZoomScale * details.scale).clamp(0.2, 8.0);
      notifier.setZoomScale(newScale);
    } else {
      // Single finger drag to scrub playhead!
      _isScrubbing = true;
      final timeMs = (details.localFocalPoint.dx / _pixelsPerMs).clamp(0.0, ed.project.durationMs);
      notifier.seekTo(timeMs);
    }
  }

  void _onScaleEnd(ScaleEndDetails _) {
    _isScrubbing = false;
  }

  void _syncPlayheadScroll(double currentTimeMs, double viewportWidth) {
    if (_isScrubbing || !_hScroll.hasClients) return;
    final playheadX = currentTimeMs * _pixelsPerMs;
    final scrollOffset = _hScroll.offset;
    final visibleLeft = scrollOffset;
    final visibleRight = scrollOffset + viewportWidth;

    // Auto-scroll to keep playhead in the right 1/3 of view when playing
    if (playheadX > visibleRight - 40 || playheadX < visibleLeft) {
      final target = (playheadX - viewportWidth * 0.3).clamp(0.0, _hScroll.position.maxScrollExtent);
      _hScroll.animateTo(target, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ed = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final tracks = ed.project.tracks;
    final durationMs = math.max(ed.project.durationMs, 15000.0);
    final ppm = (_kBasePixelsPerSecond * ed.zoomScale) / 1000.0;
    final totalW = durationMs * ppm + 120;

    // Auto-scroll during playback
    if (ed.isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncPlayheadScroll(ed.currentTimeMs, context.size?.width ?? 300);
        }
      });
    }

    return Column(
      children: [
        // ── Timeline toolbar ───────────────────────────────────────────────
        _TimelineToolbar(notifier: notifier, editorState: ed),

        // ── Main timeline body ─────────────────────────────────────────────
        Expanded(
          child: Row(
            children: [
              // Left: Track headers (fixed, non-scrolling)
              SizedBox(
                width: _kTrackHeaderWidth,
                child: Column(
                  children: [
                    // Ruler spacer
                    const SizedBox(height: _kRulerHeight),
                    // Track headers list (synced vertical scroll)
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _headerVScroll,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: tracks.map((track) {
                            final height = _trackHeight(track.type);
                            return _TrackHeader(
                              key: ValueKey('header_${track.id}'),
                              track: track,
                              height: height,
                              isSelected: ed.selectedTrackId == track.id,
                              onMute: () => notifier.toggleTrackMute(track.id),
                              onLock: () => notifier.toggleTrackLock(track.id),
                              onDelete: () => notifier.removeTrack(track.id),
                              onTap: () => notifier.selectClip(null, trackId: track.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // Add Track button
                    _AddTrackButton(onTap: () => notifier.toggleAddTrackSheet()),
                  ],
                ),
              ),

              // Right: Scrollable timeline content
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final viewW = constraints.maxWidth;
                    return Stack(
                      children: [
                        // Scrollable content
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _hScroll,
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            width: totalW,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              controller: _vScroll,
                              physics: const BouncingScrollPhysics(),
                              child: GestureDetector(
                                onTapUp: (d) => _onTimelineTap(d, viewW),
                                onScaleStart: _onScaleStart,
                                onScaleUpdate: _onScaleUpdate,
                                onScaleEnd: _onScaleEnd,
                                child: Column(
                                  children: [
                                    // Ruler
                                    _TimelineRuler(
                                      totalW: totalW,
                                      durationMs: durationMs,
                                      ppm: ppm,
                                    ),
                                    // Track clip rows
                                    ...tracks.map((track) {
                                      return _TrackClipRow(
                                        key: ValueKey('clips_${track.id}'),
                                        track: track,
                                        editorState: ed,
                                        ppm: ppm,
                                        totalWidth: totalW,
                                        onClipTap: (clipId) => notifier.selectClip(clipId, trackId: track.id),
                                        onAddMedia: () => notifier.toggleMediaBrowser(),
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Playhead needle overlay (moves with currentTime)
                        _PlayheadNeedle(
                          currentTimeMs: ed.currentTimeMs,
                          ppm: ppm,
                          scrollOffset: _hScroll.hasClients ? _hScroll.offset : 0,
                          viewportWidth: viewW,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Clip property panel (shows when a clip is selected) ─────────────
        if (ed.selectedClip != null)
          ClipPropertyPanel(
            clip: ed.selectedClip!,
            onClose: () => notifier.deselectAll(),
            onDelete: () => notifier.deleteSelectedClip(),
            onSplit: () => notifier.splitSelectedClip(),
          ),
      ],
    );
  }

  static double _trackHeight(TrackType type) {
    switch (type) {
      case TrackType.video:
      case TrackType.image:
        return _kTrackHeight;
      case TrackType.audio:
      case TrackType.voiceover:
        return _kAudioTrackHeight;
      default:
        return _kSmallTrackHeight;
    }
  }
}

// ─── Timeline Toolbar ─────────────────────────────────────────────────────────
class _TimelineToolbar extends StatelessWidget {
  final EditorNotifier notifier;
  final EditorState editorState;

  const _TimelineToolbar({required this.notifier, required this.editorState});

  @override
  Widget build(BuildContext context) {
    final zoom = editorState.zoomScale;
    final pct = (zoom * 100).round();

    return Container(
      height: 32,
      color: const Color(0xFF0E1118),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, size: 14, color: Video365Colors.secondaryText),
          const SizedBox(width: 6),
          Text(
            'TIMELINE',
            style: const TextStyle(
              color: Video365Colors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          // Zoom controls
          _IconBtn(icon: Icons.remove, tooltip: 'Zoom Out', onTap: notifier.zoomOut),
          const SizedBox(width: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2030),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$pct%',
              style: const TextStyle(
                color: Video365Colors.primaryText,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 2),
          _IconBtn(icon: Icons.add, tooltip: 'Zoom In', onTap: notifier.zoomIn),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.fit_screen_outlined, tooltip: 'Fit to Window',
            onTap: () => notifier.setZoomScale(1.0)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: Video365Colors.secondaryText),
        ),
      ),
    );
  }
}

// ─── Ruler ────────────────────────────────────────────────────────────────────
class _TimelineRuler extends StatelessWidget {
  final double totalW;
  final double durationMs;
  final double ppm;

  const _TimelineRuler({required this.totalW, required this.durationMs, required this.ppm});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kRulerHeight,
      width: totalW,
      color: const Color(0xFF0A0D14),
      child: CustomPaint(
        painter: _RulerPainter(durationMs: durationMs, ppm: ppm),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double durationMs;
  final double ppm;

  _RulerPainter({required this.durationMs, required this.ppm});

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()..color = const Color(0xFF2A3448)..strokeWidth = 1;
    final majorPaint = Paint()..color = const Color(0xFF4A5568)..strokeWidth = 1.2;

    final totalSec = (durationMs / 1000).ceil() + 5;
    final pixPerSec = ppm * 1000;

    // Choose tick interval based on zoom
    int majorInterval = 1;
    if (pixPerSec < 20) majorInterval = 10;
    else if (pixPerSec < 40) majorInterval = 5;
    else if (pixPerSec < 80) majorInterval = 2;

    for (int s = 0; s <= totalSec; s++) {
      final x = s * pixPerSec;
      final isMajor = s % majorInterval == 0;

      if (isMajor) {
        canvas.drawLine(Offset(x, size.height - 12), Offset(x, size.height), majorPaint);
        final m = s ~/ 60;
        final sec = s % 60;
        final label = '${m > 0 ? '${m}m' : ''}${sec}s';
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5, fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 2, 2));
      } else {
        canvas.drawLine(Offset(x, size.height - 6), Offset(x, size.height), minorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.durationMs != durationMs || old.ppm != ppm;
}

// ─── Track Header ─────────────────────────────────────────────────────────────
class _TrackHeader extends StatelessWidget {
  final TrackItem track;
  final double height;
  final bool isSelected;
  final VoidCallback onMute;
  final VoidCallback onLock;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TrackHeader({
    super.key,
    required this.track,
    required this.height,
    required this.isSelected,
    required this.onMute,
    required this.onLock,
    required this.onDelete,
    required this.onTap,
  });

  Color get _trackColor {
    switch (track.type) {
      case TrackType.video: return const Color(0xFF1565C0);
      case TrackType.image: return const Color(0xFF0891B2);
      case TrackType.audio: return const Color(0xFF4F46E5);
      case TrackType.voiceover: return const Color(0xFF059669);
      case TrackType.text: return const Color(0xFF7C3AED);
      case TrackType.effect: return const Color(0xFFF59E0B);
      case TrackType.adjustment: return const Color(0xFFDC2626);
      default: return const Color(0xFF374151);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? _trackColor.withValues(alpha: 0.18) : const Color(0xFF0D1117),
          border: Border(
            right: BorderSide(color: _trackColor, width: 2.5),
            bottom: const BorderSide(color: Color(0xFF1A2030), width: 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(track.type.icon, size: 10, color: _trackColor),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    track.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SmallIconBtn(
                  icon: track.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: track.isMuted ? const Color(0xFFEF5350) : const Color(0xFF475569),
                  onTap: onMute,
                ),
                const SizedBox(width: 5),
                _SmallIconBtn(
                  icon: track.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: track.isLocked ? const Color(0xFFF59E0B) : const Color(0xFF475569),
                  onTap: onLock,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallIconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 9, color: color),
    );
  }
}

// ─── Add Track Button ─────────────────────────────────────────────────────────
class _AddTrackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTrackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kTrackHeaderWidth,
        height: 36,
        color: const Color(0xFF0A0D14),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 14, color: Video365Colors.activeGreen),
            SizedBox(height: 2),
            Text(
              'Track',
              style: TextStyle(
                color: Video365Colors.activeGreen,
                fontSize: 7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Clip Row ─────────────────────────────────────────────────────────────────
class _TrackClipRow extends StatelessWidget {
  final TrackItem track;
  final EditorState editorState;
  final double ppm;
  final double totalWidth;
  final void Function(String clipId) onClipTap;
  final VoidCallback onAddMedia;

  const _TrackClipRow({
    super.key,
    required this.track,
    required this.editorState,
    required this.ppm,
    required this.totalWidth,
    required this.onClipTap,
    required this.onAddMedia,
  });

  double get _height {
    switch (track.type) {
      case TrackType.video:
      case TrackType.image:
        return _kTrackHeight;
      case TrackType.audio:
      case TrackType.voiceover:
        return _kAudioTrackHeight;
      default:
        return _kSmallTrackHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHidden = track.isHidden;

    return Container(
      height: _height,
      width: totalWidth,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(bottom: BorderSide(color: Color(0xFF1A2030), width: 1)),
      ),
      child: isHidden
          ? const SizedBox()
          : track.clips.isEmpty
              ? _EmptyTrackHint(track: track, onAddMedia: onAddMedia)
              : Stack(
                  clipBehavior: Clip.none,
                  children: track.clips.map((clip) {
                    final left = clip.startMs * ppm;
                    final width = math.max(clip.durationMs * ppm, 24.0);
                    final isSelected = editorState.selectedClipId == clip.id;
                    final notifier = editorState.project.tracks.isNotEmpty
                        ? (clip) // reference
                        : null;

                    return Positioned(
                      left: left,
                      top: 2,
                      bottom: 2,
                      width: width,
                      child: GestureDetector(
                        onTap: () => onClipTap(clip.id),
                        child: _ClipBlock(
                          clip: clip,
                          width: width,
                          height: _height - 4,
                          isSelected: isSelected,
                          trackType: track.type,
                          ppm: ppm,
                        ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}

// ─── Empty Track Hint ─────────────────────────────────────────────────────────
class _EmptyTrackHint extends StatelessWidget {
  final TrackItem track;
  final VoidCallback onAddMedia;

  const _EmptyTrackHint({required this.track, required this.onAddMedia});

  @override
  Widget build(BuildContext context) {
    final isMedia = track.type == TrackType.video ||
        track.type == TrackType.audio ||
        track.type == TrackType.image;

    return GestureDetector(
      onTap: isMedia ? onAddMedia : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMedia ? Icons.add_circle_outline : Icons.info_outline,
              size: 12,
              color: isMedia ? Video365Colors.activeGreen : const Color(0xFF374151),
            ),
            const SizedBox(width: 6),
            Text(
              isMedia ? 'Add ${track.type.label}' : 'Empty track',
              style: TextStyle(
                color: isMedia ? Video365Colors.activeGreen : const Color(0xFF374151),
                fontSize: 10,
                fontWeight: isMedia ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Clip Block ───────────────────────────────────────────────────────────────
class _ClipBlock extends ConsumerWidget {
  final ClipItem clip;
  final double width;
  final double height;
  final bool isSelected;
  final TrackType trackType;
  final double ppm;

  const _ClipBlock({
    required this.clip,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.trackType,
    required this.ppm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(editorProvider.notifier);
    final isAudio = trackType == TrackType.audio || trackType == TrackType.voiceover;
    final isVideo = trackType == TrackType.video || trackType == TrackType.image;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: clip.color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Colors.white : clip.color,
          width: isSelected ? 2.0 : 0.8,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: clip.color.withValues(alpha: 0.5), blurRadius: 8)]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Audio waveform background
          if (isAudio)
            Positioned.fill(
              child: CustomPaint(
                painter: _WaveformPainter(color: Colors.white.withValues(alpha: 0.40)),
              ),
            ),

          // Video filmstrip overlay
          if (isVideo && width > 30)
            Positioned.fill(
              child: Row(
                children: List.generate(
                  math.max(1, (width / 32).floor()),
                  (i) => Container(
                    width: 32,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.black.withValues(alpha: 0.3), width: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 10,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Clip title
          if (width > 28)
            Positioned(
              left: isSelected ? 14 : 6,
              top: 0,
              bottom: 0,
              right: isSelected ? 14 : 6,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  clip.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          // Clip Body Gesture Handler (Drag to Move along timeline & Long Press)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => notifier.selectClip(clip.id),
              onDoubleTap: () => notifier.selectClip(clip.id),
              onLongPress: () {
                HapticFeedback.heavyImpact();
                notifier.selectClip(clip.id);
                notifier.setBottomTool(BottomTool.trim);
              },
              onHorizontalDragUpdate: isSelected
                  ? (details) {
                      final deltaMs = details.delta.dx / ppm;
                      notifier.moveClip(clip.id, clip.startMs + deltaMs);
                    }
                  : null,
            ),
          ),

          // Selection Left Trim Handle (Drag to Trim Start)
          if (isSelected)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 14,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final deltaMs = details.delta.dx / ppm;
                  notifier.trimClipStart(clip.id, clip.startMs + deltaMs);
                },
                child: Container(
                  color: Colors.white,
                  child: const Center(
                    child: Icon(Icons.drag_indicator_rounded, size: 10, color: Colors.black),
                  ),
                ),
              ),
            ),

          // Selection Right Trim Handle (Drag to Trim End)
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 14,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final deltaMs = details.delta.dx / ppm;
                  notifier.trimClipEnd(clip.id, clip.endMs + deltaMs);
                },
                child: Container(
                  color: Colors.white,
                  child: const Center(
                    child: Icon(Icons.drag_indicator_rounded, size: 10, color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Playhead Needle ──────────────────────────────────────────────────────────
class _PlayheadNeedle extends StatefulWidget {
  final double currentTimeMs;
  final double ppm;
  final double scrollOffset;
  final double viewportWidth;

  const _PlayheadNeedle({
    required this.currentTimeMs,
    required this.ppm,
    required this.scrollOffset,
    required this.viewportWidth,
  });

  @override
  State<_PlayheadNeedle> createState() => _PlayheadNeedleState();
}

class _PlayheadNeedleState extends State<_PlayheadNeedle> {
  @override
  Widget build(BuildContext context) {
    // Calculate screen X of playhead (accounting for horizontal scroll)
    final playheadAbsoluteX = widget.currentTimeMs * widget.ppm;
    final playheadScreenX = playheadAbsoluteX - widget.scrollOffset;

    // Only paint if visible
    if (playheadScreenX < -4 || playheadScreenX > widget.viewportWidth + 4) {
      return const SizedBox();
    }

    final totalSec = widget.currentTimeMs / 1000;
    final m = totalSec ~/ 60;
    final s = totalSec.toInt() % 60;
    final ms = ((totalSec - totalSec.floor()) * 10).toInt();
    final label = '${m > 0 ? '$m:' : ''}${s.toString().padLeft(2, '0')}.$ms';

    return Positioned(
      left: playheadScreenX - 1,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: SizedBox(
          width: 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Needle line
              Positioned(
                top: _kRulerHeight - 4,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 2,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    boxShadow: [BoxShadow(color: Color(0x88EF4444), blurRadius: 6)],
                  ),
                ),
              ),
              // Timecode pill at top
              Positioned(
                top: 2,
                left: -22,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              // Triangle top cap
              Positioned(
                top: _kRulerHeight - 6,
                left: -4,
                child: const Icon(Icons.arrow_drop_down, size: 10, color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Waveform Painter ─────────────────────────────────────────────────────────
class _WaveformPainter extends CustomPainter {
  final Color color;
  _WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final center = size.height / 2;
    final step = size.width / math.max(1, size.width / 3).floor();
    int i = 0;
    for (double x = 0; x < size.width; x += step, i++) {
      final ratio = (math.sin(i * 0.6) * 0.4 + math.cos(i * 1.1) * 0.3).abs() + 0.1;
      final half = (size.height * 0.75) * ratio / 2;
      canvas.drawLine(Offset(x, center - half), Offset(x, center + half), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.color != color;
}
