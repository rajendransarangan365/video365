import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';

class BottomToolBar extends ConsumerWidget {
  const BottomToolBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Video365Colors.secondaryBg,
        border: Border(
          top: BorderSide(color: Video365Colors.cardBorder, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // 1. Text (Matching Reference Image 1)
            _buildToolItem(
              label: 'Text',
              isActive: editorState.activeTool == BottomTool.text,
              onTap: () => editorNotifier.setBottomTool(BottomTool.text),
              icon: Icons.title_rounded,
            ),
            const SizedBox(width: 8),

            // 2. Music (Matching Reference Image 1)
            _buildToolItem(
              label: 'Music',
              isActive: editorState.activeTool == BottomTool.audio,
              onTap: () => editorNotifier.toggleMediaBrowser(),
              icon: Icons.music_note_rounded,
            ),
            const SizedBox(width: 8),

            // 3. Stickers / Overlays (Matching Reference Image 1)
            _buildToolItem(
              label: 'Stickers',
              isActive: editorState.isMediaBrowserOpen,
              onTap: () => editorNotifier.toggleMediaBrowser(),
              icon: Icons.auto_awesome_mosaic_rounded,
            ),
            const SizedBox(width: 8),

            // 4. Split (Matching Reference Image 1) - Instant cut at playhead needle!
            _buildToolItem(
              label: 'Split',
              isActive: false,
              onTap: () {
                editorNotifier.splitAtPlayhead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clip split at needle position!'),
                    duration: Duration(milliseconds: 900),
                    backgroundColor: Video365Colors.activeGreen,
                  ),
                );
              },
              icon: Icons.content_cut_rounded,
            ),
            const SizedBox(width: 8),

            // 5. Filter (Matching Reference Image 1)
            _buildToolItem(
              label: 'Filter',
              isActive: editorState.activeTool == BottomTool.filters,
              onTap: () => editorNotifier.setBottomTool(BottomTool.filters),
              icon: Icons.tune_rounded,
            ),
            const SizedBox(width: 8),

            // 6. Effects / Transitions
            _buildToolItem(
              label: 'Effects',
              isActive: editorState.activeTool == BottomTool.effects,
              onTap: () => editorNotifier.setBottomTool(BottomTool.effects),
              icon: Icons.auto_fix_high_rounded,
            ),
            const SizedBox(width: 8),

            // 7. Speed Curve
            _buildToolItem(
              label: 'Speed',
              isActive: editorState.activeTool == BottomTool.speed,
              onTap: () => editorNotifier.setBottomTool(BottomTool.speed),
              icon: Icons.speed_rounded,
            ),
            const SizedBox(width: 8),

            // 8. Auto Captions
            _buildToolItem(
              label: 'Captions',
              isActive: editorState.isCaptionsSheetOpen,
              onTap: () => editorNotifier.toggleCaptionsSheet(),
              icon: Icons.subtitles_rounded,
            ),
            const SizedBox(width: 8),

            // 9. Radial Menu Wheel
            _buildToolItem(
              label: 'Wheel',
              isActive: editorState.isRadialMenuOpen,
              onTap: () => editorNotifier.toggleRadialMenu(),
              icon: Icons.album_outlined,
            ),
            const SizedBox(width: 8),

            // 10. Add Media
            _buildToolItem(
              label: 'Media',
              isActive: editorState.isMediaBrowserOpen,
              onTap: () => editorNotifier.toggleMediaBrowser(),
              icon: Icons.add_photo_alternate_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final activeColor = isActive ? Video365Colors.activeGreen : Video365Colors.secondaryText;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Video365Colors.activeGreen.withValues(alpha: 0.12) : const Color(0xFF131722),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Video365Colors.activeGreen.withValues(alpha: 0.4) : const Color(0xFF22283A),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: activeColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: activeColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
