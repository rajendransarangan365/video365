import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';

class SpeedDrawer extends ConsumerWidget {
  const SpeedDrawer({super.key});

  static const List<double> _speeds = [0.25, 0.5, 1.0, 1.5, 2.0, 4.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Video365Colors.secondaryBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Video365Colors.cardBorder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.timer_outlined, color: Video365Colors.activeGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Speed Ramping & Duration Controls',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Video365Colors.secondaryText, size: 20),
                onPressed: () => editorNotifier.closeActiveDrawer(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Speed Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _speeds.map((speed) {
              final isSelected = (editorState.playbackSpeed - speed).abs() < 0.05;

              return GestureDetector(
                onTap: () => editorNotifier.setClipSpeed(speed),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Video365Colors.activeGreen : Video365Colors.panelBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.white : Video365Colors.cardBorder,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF080A0E) : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          // Pitch Correction Row
          Row(
            children: [
              const Icon(Icons.music_note_rounded, color: Video365Colors.secondaryText, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Preserve audio pitch during speed change',
                style: TextStyle(color: Video365Colors.secondaryText, fontSize: 12),
              ),
              const Spacer(),
              Switch(
                value: true,
                activeColor: Video365Colors.activeGreen,
                onChanged: (_) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

