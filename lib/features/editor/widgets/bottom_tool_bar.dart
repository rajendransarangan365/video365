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
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: const BoxDecoration(
        color: Video365Colors.secondaryBg,
        border: Border(
          top: BorderSide(color: Video365Colors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 0. Add Media
          _buildToolItem(
            label: 'Media',
            isActive: editorState.isMediaBrowserOpen,
            onTap: () => editorNotifier.toggleMediaBrowser(),
            icon: Icons.add_circle_outline_rounded,
          ),

          // 1. Trim
          _buildToolItem(
            label: 'Trim',
            isActive: editorState.activeTool == BottomTool.trim,
            onTap: () => editorNotifier.setBottomTool(BottomTool.trim),
            icon: Icons.content_cut_rounded,
          ),

          // 2. Text / Lower Thirds
          _buildToolItem(
            label: 'Text',
            isActive: editorState.activeTool == BottomTool.text,
            onTap: () => editorNotifier.setBottomTool(BottomTool.text),
            icon: Icons.title_rounded,
          ),

          // 3. Audio
          _buildToolItem(
            label: 'Audio',
            isActive: editorState.activeTool == BottomTool.audio,
            onTap: () => editorNotifier.toggleMediaBrowser(),
            icon: Icons.music_note_rounded,
          ),

          // 4. Filters & LUTs
          _buildToolItem(
            label: 'Filters',
            isActive: editorState.activeTool == BottomTool.filters,
            onTap: () => editorNotifier.setBottomTool(BottomTool.filters),
            icon: Icons.tune_rounded,
          ),

          // 5. Effects / FX
          _buildToolItem(
            label: 'Effects',
            isActive: editorState.activeTool == BottomTool.effects,
            onTap: () => editorNotifier.setBottomTool(BottomTool.effects),
            icon: Icons.bolt_rounded,
          ),

          // 6. Speed
          _buildToolItem(
            label: 'Speed',
            isActive: editorState.activeTool == BottomTool.speed,
            onTap: () => editorNotifier.setBottomTool(BottomTool.speed),
            icon: Icons.timer_outlined,
          ),

          // 7. Auto Captions
          _buildToolItem(
            label: 'Captions',
            isActive: editorState.isCaptionsSheetOpen,
            onTap: () => editorNotifier.toggleCaptionsSheet(),
            icon: Icons.subtitles_rounded,
          ),

          // 8. Radial Dial / Wheel
          _buildToolItem(
            label: 'Wheel',
            isActive: editorState.isRadialMenuOpen,
            onTap: () => editorNotifier.toggleRadialMenu(),
            icon: Icons.album_outlined,
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: isActive
                  ? BoxDecoration(
                      color: Video365Colors.activeGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(
                icon,
                size: 20,
                color: activeColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: activeColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
