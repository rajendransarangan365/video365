import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';
import 'clip_property_panel.dart';

// ─── Constants ────────────────────────────────────────────────────────────────
const double _kTrackHeaderWidth = 54.0;
const double _kTrackHeight = 48.0;
const double _kAudioTrackHeight = 42.0;
const double _kSmallTrackHeight = 38.0;
const double _kRulerHeight = 26.0;
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
    HapticFeedback.selectionClick();

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
      // Two-finger pinch to zoom in/out
      final newScale = (_baseZoomScale * details.scale).clamp(0.2, 8.0);
      notifier.setZoomScale(newScale);
    } else {
      // Single finger drag to scrub playhead
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

    // Smooth auto-scroll during playback to keep needle within comfortable view
    if (playheadX > visibleRight - 60 || playheadX < visibleLeft) {
      final target = (playheadX - viewportWidth * 0.35).clamp(0.0, _hScroll.position.maxScrollExtent);
      _hScroll.animateTo(target, duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ed = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final tracks = ed.project.tracks;
    final durationMs = math.max(ed.project.durationMs, 15000.0);
    final ppm = (_kBasePixelsPerSecond * ed.zoomScale) / 1000.0;
    final totalW = durationMs * ppm + 160;

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
        // ── 1. Timeline Top Toolbar (Matching Reference Image 1 & 2) ──────
        _TimelineToolbar(notifier: notifier, editorState: ed),

        // ── 2. Main Timeline Body ─────────────────────────────────────────
        Expanded(
          child: Row(
            children: [
              // Left: Track Headers (Fixed Column)
              SizedBox(
                width: _kTrackHeaderWidth,
                child: Column(
                  children: [
                    // Ruler header corner: Quick + Track button
                    _AddTrackCornerButton(
                      onTap: () => notifier.toggleAddTrackSheet(),
                    ),
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
                  ],
                ),
              ),

              // Right: Horizontally Scrollable Tracks with In-Sync Needle
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final viewW = constraints.maxWidth;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _hScroll,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: totalW,
                        child: Stack(
                          children: [
                            // 2.1 Tracks & Ruler Content
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              controller: _vScroll,
                              physics: const BouncingScrollPhysics(),
                              child: GestureDetector(
                                onTapUp: (d) => _onTimelineTap(d, viewW),
                                onScaleStart: _onScaleStart,
                                onScaleUpdate: _onScaleUpdate,
                                onScaleEnd: _onScaleEnd,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ruler (Markings: 0s · · 8s · · 16s · ·)
                                    _TimelineRuler(
                                      totalW: totalW,
                                      durationMs: durationMs,
                                      ppm: ppm,
                                      onSeek: (ms) => notifier.seekTo(ms),
                                    ),
                                    // Track Clip Rows
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
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),

                            // 2.2 Playhead Needle (100% In-Sync, Never Jumps or Drifts)
                            Positioned(
                              left: (ed.currentTimeMs * ppm) - 24,
                              top: 0,
                              bottom: 0,
                              width: 48,
                              child: _InteractivePlayheadNeedle(
                                currentTimeMs: ed.currentTimeMs,
                                ppm: ppm,
                                onSeek: (ms) => notifier.seekTo(ms),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── 3. Clip Property Panel (Shows when a clip is selected) ─────────
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

// ─── Timeline Toolbar (Matching Reference Image 1 & 2) ────────────────────────
class _TimelineToolbar extends StatelessWidget {
  final EditorNotifier notifier;
  final EditorState editorState;

  const _TimelineToolbar({required this.notifier, required this.editorState});

  String _formatTime(double timeMs) {
    final totalSeconds = timeMs / 1000.0;
    final seconds = totalSeconds.toInt();
    final tenths = ((totalSeconds - seconds) * 10).toInt();
    return '${seconds}s';
  }

  String _formatDetailed(double timeMs) {
    final totalSeconds = timeMs / 1000.0;
    final seconds = totalSeconds.toInt();
    final tenths = ((totalSeconds - seconds) * 100).toInt();
    return '$seconds.${tenths.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final zoom = editorState.zoomScale;
    final pct = (zoom * 100).round();
    final currentStr = _formatDetailed(editorState.currentTimeMs);
    final totalStr = _formatDetailed(editorState.project.durationMs > 0 ? editorState.project.durationMs : 15000.0);

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0E14),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E2536), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Left: "Timeline  4.93s / 29.04s" (Matching Reference Image 1)
          const Text(
            'Timeline',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF141923),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF222B3D), width: 0.8),
            ),
            child: Text(
              '$currentStr / $totalStr',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),

          const Spacer(),

          // Center: Zoom Controls [- 80% +] (Matching Reference Image 2)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBtn(
                icon: Icons.remove_rounded,
                tooltip: 'Zoom Out',
                onTap: () {
                  notifier.zoomOut();
                  HapticFeedback.selectionClick();
                },
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () {
                  notifier.setZoomScale(1.0);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19202E),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$pct%',
                    style: const TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              _IconBtn(
                icon: Icons.add_rounded,
                tooltip: 'Zoom In',
                onTap: () {
                  notifier.zoomIn();
                  HapticFeedback.selectionClick();
                },
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Right: Undo ↺ & Redo ↻ Buttons (Matching Reference Image 1)
          _IconBtn(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            color: notifier.canUndo ? Colors.white : const Color(0xFF475569),
            onTap: () {
              if (notifier.canUndo) {
                notifier.undo();
                HapticFeedback.lightImpact();
              }
            },
          ),
          const SizedBox(width: 4),
          _IconBtn(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            color: notifier.canRedo ? Colors.white : const Color(0xFF475569),
            onTap: () {
              if (notifier.canRedo) {
                notifier.redo();
                HapticFeedback.lightImpact();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _IconBtn({required this.icon, required this.tooltip, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          child: Icon(icon, size: 15, color: color ?? const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}

// ─── Ruler Corner Button (+ Track) ────────────────────────────────────────────
class _AddTrackCornerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTrackCornerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _kTrackHeaderWidth,
        height: _kRulerHeight,
        decoration: const BoxDecoration(
          color: Color(0xFF090C12),
          border: Border(
            bottom: BorderSide(color: Color(0xFF1E2536), width: 1),
            right: BorderSide(color: Color(0xFF1E2536), width: 1),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_rounded, size: 14, color: Video365Colors.activeGreen),
            SizedBox(width: 2),
            Text(
              'Track',
              style: TextStyle(
                color: Video365Colors.activeGreen,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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
  final void Function(double) onSeek;

  const _TimelineRuler({
    required this.totalW,
    required this.durationMs,
    required this.ppm,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final timeMs = (details.localPosition.dx / ppm).clamp(0.0, durationMs);
        onSeek(timeMs);
        HapticFeedback.selectionClick();
      },
      onHorizontalDragStart: (details) {
        final timeMs = (details.localPosition.dx / ppm).clamp(0.0, durationMs);
        onSeek(timeMs);
        HapticFeedback.selectionClick();
      },
      onHorizontalDragUpdate: (details) {
        final timeMs = (details.localPosition.dx / ppm).clamp(0.0, durationMs);
        onSeek(timeMs);
        HapticFeedback.selectionClick();
      },
      child: Container(
        height: _kRulerHeight,
        width: totalW,
        color: const Color(0xFF0A0D14),
        child: CustomPaint(
          painter: _RulerPainter(durationMs: durationMs, ppm: ppm),
        ),
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
    final minorPaint = Paint()..color = const Color(0xFF232D3F)..strokeWidth = 1;
    final majorPaint = Paint()..color = const Color(0xFF475569)..strokeWidth = 1.2;

    final totalSec = (durationMs / 1000).ceil() + 10;
    final pixPerSec = ppm * 1000;

    // Tick intervals matching Reference Image 1 (0s · · 8s · · 16s · · 24s)
    int majorInterval = 1;
    if (pixPerSec < 15) majorInterval = 10;
    else if (pixPerSec < 35) majorInterval = 8;
    else if (pixPerSec < 60) majorInterval = 4;
    else if (pixPerSec < 120) majorInterval = 2;

    for (int s = 0; s <= totalSec; s++) {
      final x = s * pixPerSec;
      final isMajor = s % majorInterval == 0;

      if (isMajor) {
        canvas.drawLine(Offset(x, size.height - 10), Offset(x, size.height), majorPaint);
        final m = s ~/ 60;
        final sec = s % 60;
        final label = '${m > 0 ? '${m}m ' : ''}${sec}s';
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 3, 3));
      } else {
        // Minor dot or tick
        canvas.drawLine(Offset(x, size.height - 5), Offset(x, size.height), minorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.durationMs != durationMs || old.ppm != ppm;
}

// ─── Track Header (Left Column) ───────────────────────────────────────────────
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? _trackColor.withValues(alpha: 0.22) : const Color(0xFF0D1117),
          border: Border(
            right: BorderSide(color: _trackColor, width: 3.0),
            bottom: const BorderSide(color: Color(0xFF1A2030), width: 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Track Type Icon & Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(track.type.icon, size: 12, color: _trackColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    track.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            // Track Quick Toggles: Mute & Lock
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onMute,
                  child: Icon(
                    track.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    size: 11,
                    color: track.isMuted ? const Color(0xFFEF4444) : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onLock,
                  child: Icon(
                    track.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    size: 11,
                    color: track.isLocked ? const Color(0xFFF59E0B) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Track Clip Row ───────────────────────────────────────────────────────────
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
                  children: [
                    ...track.clips.map((clip) {
                      final left = clip.startMs * ppm;
                      final width = math.max(clip.durationMs * ppm, 28.0);
                      final isSelected = editorState.selectedClipId == clip.id;

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
                    }),
                  ],
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
    return GestureDetector(
      onTap: onAddMedia,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 13,
              color: Video365Colors.activeGreen,
            ),
            const SizedBox(width: 6),
            Text(
              'Add ${track.type.label}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Clip Block (Matching Reference Images 1, 2 & 5) ──────────────────────────
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

  String _formatDuration(double durationMs) {
    final s = (durationMs / 1000).round();
    return '${s}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(editorProvider.notifier);
    final isAudio = trackType == TrackType.audio || trackType == TrackType.voiceover;
    final isVideo = trackType == TrackType.video || trackType == TrackType.image;
    final isText = trackType == TrackType.text;
    final isEffect = trackType == TrackType.effect || trackType == TrackType.adjustment;

    Color baseColor;
    if (isVideo) baseColor = const Color(0xFF1E3A8A); // Deep Blue
    else if (isAudio) baseColor = const Color(0xFF4338CA); // Indigo
    else if (isText) baseColor = const Color(0xFF6D28D9); // Violet
    else baseColor = const Color(0xFFD97706); // Warm Amber

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.white : baseColor.withValues(alpha: 0.6),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Audio waveform visualization
          if (isAudio)
            Positioned.fill(
              child: CustomPaint(
                painter: _WaveformPainter(color: Colors.white.withValues(alpha: 0.45)),
              ),
            ),

          // Video filmstrip thumbnails overlay
          if (isVideo && width > 40)
            Positioned.fill(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      math.max(1, (width / 36).ceil()),
                      (i) => Container(
                        width: 36,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.black.withValues(alpha: 0.3), width: 0.8),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Clip Content Info
          Positioned(
            left: isSelected ? 18 : 8,
            top: 0,
            bottom: 0,
            right: isSelected ? 18 : 8,
            child: Row(
              children: [
                // Duration Badge: "14 Sec" (Matching Reference Image 5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(clip.durationMs),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    clip.textContent ?? clip.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Selected Handles: Left White Grab Handle (<)
          if (isSelected)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final deltaMs = details.primaryDelta! / ppm;
                  notifier.trimClipStart(clip.id, clip.startMs + deltaMs);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.chevron_left_rounded, size: 14, color: Colors.black),
                  ),
                ),
              ),
            ),

          // Selected Handles: Right White Grab Handle (>)
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final deltaMs = details.primaryDelta! / ppm;
                  notifier.trimClipEnd(clip.id, clip.endMs + deltaMs);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.chevron_right_rounded, size: 14, color: Colors.black),
                  ),
                ),
              ),
            ),

          // Horizontal Drag to Move Clip Body
          Positioned(
            left: isSelected ? 16 : 0,
            right: isSelected ? 16 : 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                final deltaMs = details.primaryDelta! / ppm;
                notifier.moveClip(clip.id, clip.startMs + deltaMs);
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
                notifier.selectClip(clip.id, trackId: clip.trackId);
                notifier.setBottomTool(BottomTool.trim);
              },
              onDoubleTap: () {
                notifier.selectClip(clip.id, trackId: clip.trackId);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Interactive Playhead Needle (100% In-Sync, Matching Ref Images 1, 5 & 8) ─
class _InteractivePlayheadNeedle extends StatelessWidget {
  final double currentTimeMs;
  final double ppm;
  final void Function(double) onSeek;

  const _InteractivePlayheadNeedle({
    required this.currentTimeMs,
    required this.ppm,
    required this.onSeek,
  });

  String _formatTimePill(double ms) {
    final totalSec = ms / 1000.0;
    final s = totalSec.toInt();
    final tenths = ((totalSec - s) * 10).toInt();
    return '$s.${tenths}s';
  }

  @override
  Widget build(BuildContext context) {
    final pillLabel = _formatTimePill(currentTimeMs);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => HapticFeedback.selectionClick(),
      onHorizontalDragUpdate: (details) {
        final deltaMs = details.primaryDelta! / ppm;
        onSeek(math.max(0.0, currentTimeMs + deltaMs));
        HapticFeedback.selectionClick();
      },
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Vertical White Needle Line
          Positioned(
            top: _kRulerHeight - 4,
            bottom: 0,
            left: 23,
            child: Container(
              width: 2.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xAAFFFFFF),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),

          // 2. White Time Capsule Pill at Top (Matching Reference Image 1 & 8)
          Positioned(
            top: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                pillLabel,
                style: const TextStyle(
                  color: Color(0xFF080A0E),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),

          // 3. Pointer Triangle under Pill
          Positioned(
            top: _kRulerHeight - 6,
            left: 18,
            child: const Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Audio Waveform Canvas Painter ────────────────────────────────────────────
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
      final ratio = (math.sin(i * 0.6) * 0.4 + math.cos(i * 1.1) * 0.3).abs() + 0.12;
      final half = (size.height * 0.75) * ratio / 2;
      canvas.drawLine(Offset(x, center - half), Offset(x, center + half), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.color != color;
}
