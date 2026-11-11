import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';

class PlaybackTimecodeBar extends ConsumerWidget {
  const PlaybackTimecodeBar({super.key});

  String _formatTime(double timeMs) {
    final totalSeconds = timeMs / 1000.0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds.toInt() % 60;
    final tenths = ((totalSeconds - totalSeconds.toInt()) * 10).toInt();
    return '$minutes:${seconds.toString().padLeft(2, '0')}.$tenths';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    final currentTimeStr = _formatTime(editorState.currentTimeMs);
    final totalDurationStr = _formatTime(editorState.project.durationMs);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Timecode 0:04.2 / 0:14.0
          Row(
            children: [
              Text(
                currentTimeStr,
                style: const TextStyle(
                  color: Video365Colors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(
                  color: Video365Colors.secondaryText,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                totalDurationStr,
                style: const TextStyle(
                  color: Video365Colors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Center: Circular Play/Pause Button (matching Screenshot 4 Screen 1)
          GestureDetector(
            onTap: () => editorNotifier.togglePlay(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Video365Colors.panelBg,
                border: Border.all(
                  color: editorState.isPlaying
                      ? Video365Colors.activeGreen
                      : Colors.white24,
                  width: 1.5,
                ),
                boxShadow: editorState.isPlaying
                    ? [
                        BoxShadow(
                          color: Video365Colors.activeGreen.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Icon(
                editorState.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: editorState.isPlaying
                    ? Video365Colors.activeGreen
                    : Colors.white,
                size: 24,
              ),
            ),
          ),

          // Right: Format Badge 1080p · 30fps
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${editorState.project.resolution.label.split(' ').first} · ${editorState.project.fps.label.split(' ').first}',
                style: const TextStyle(
                  color: Video365Colors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
