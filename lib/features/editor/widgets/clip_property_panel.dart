import 'package:flutter/material.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';

/// Shows inline when a clip is selected on the timeline.
/// Displays clip info, quick actions, and basic property controls.
class ClipPropertyPanel extends StatelessWidget {
  final ClipItem clip;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final VoidCallback onSplit;
  final VoidCallback onDuplicate;
  final VoidCallback onColor;
  final VoidCallback onSpeed;
  final VoidCallback onFX;
  final VoidCallback onTransform;
  final VoidCallback? onExtractAudio;

  const ClipPropertyPanel({
    super.key,
    required this.clip,
    required this.onClose,
    required this.onDelete,
    required this.onSplit,
    required this.onDuplicate,
    required this.onColor,
    required this.onSpeed,
    required this.onFX,
    required this.onTransform,
    this.onExtractAudio,
  });

  String _formatMs(double ms) {
    final totalSec = ms / 1000;
    final m = totalSec ~/ 60;
    final s = totalSec.toInt() % 60;
    final f = ((totalSec - totalSec.floor()) * 10).toInt();
    return '${m > 0 ? '$m:' : ''}${s.toString().padLeft(2, '0')}.${f}s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: const BoxDecoration(
        color: Color(0xFF11151D),
        border: Border(top: BorderSide(color: Color(0xFF20283A), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: clip.color.withOpacity(0.12),
              border: Border(bottom: BorderSide(color: clip.color.withOpacity(0.3), width: 1)),
            ),
            child: Row(
              children: [
                Icon(clip.type.icon, size: 14, color: clip.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    clip.title,
                    style: const TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Timing info
                Text(
                  '${_formatMs(clip.startMs)} → ${_formatMs(clip.endMs)}  |  ${_formatMs(clip.durationMs)}',
                  style: const TextStyle(
                    color: Video365Colors.secondaryText,
                    fontSize: 9.5,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded, size: 16, color: Video365Colors.secondaryText),
                ),
              ],
            ),
          ),

          // ── Quick Actions ─────────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _ActionChip(
                    icon: Icons.content_cut_rounded,
                    label: 'Split',
                    color: const Color(0xFF20C878),
                    onTap: onSplit,
                  ),
                  const SizedBox(width: 6),
                  _ActionChip(
                    icon: Icons.copy_rounded,
                    label: 'Duplicate',
                    color: const Color(0xFF64748B),
                    onTap: onDuplicate,
                  ),
                  const SizedBox(width: 6),
                  if (clip.type == TrackType.video) ...[
                    _ActionChip(
                      icon: Icons.music_note_rounded,
                      label: 'Extract Audio',
                      color: const Color(0xFF06B6D4),
                      onTap: onExtractAudio ?? () {},
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (clip.type == TrackType.video || clip.type == TrackType.image) ...[
                    _ActionChip(
                      icon: Icons.tune_rounded,
                      label: 'Color',
                      color: const Color(0xFFF59E0B),
                      onTap: onColor,
                    ),
                    const SizedBox(width: 6),
                    _ActionChip(
                      icon: Icons.speed_rounded,
                      label: 'Speed',
                      color: const Color(0xFF7C3AED),
                      onTap: onSpeed,
                    ),
                    const SizedBox(width: 6),
                    _ActionChip(
                      icon: Icons.auto_fix_high_rounded,
                      label: 'FX',
                      color: const Color(0xFF0891B2),
                      onTap: onFX,
                    ),
                    const SizedBox(width: 6),
                    _ActionChip(
                      icon: Icons.crop_rotate_rounded,
                      label: 'Transform',
                      color: const Color(0xFF059669),
                      onTap: onTransform,
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (clip.type == TrackType.audio || clip.type == TrackType.voiceover) ...[
                    _ActionChip(
                      icon: Icons.speed_rounded,
                      label: 'Speed',
                      color: const Color(0xFF7C3AED),
                      onTap: onSpeed,
                    ),
                    const SizedBox(width: 6),
                    _ActionChip(
                      icon: Icons.graphic_eq_rounded,
                      label: 'Volume',
                      color: const Color(0xFF4F46E5),
                      onTap: onTransform,
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (clip.type == TrackType.text) ...[
                    _ActionChip(
                      icon: Icons.crop_rotate_rounded,
                      label: 'Transform',
                      color: const Color(0xFF059669),
                      onTap: onTransform,
                    ),
                    const SizedBox(width: 6),
                  ],
                  _ActionChip(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: const Color(0xFFEF5350),
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

