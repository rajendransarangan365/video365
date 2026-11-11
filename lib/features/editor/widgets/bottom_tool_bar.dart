import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../core/widgets/video365_icons.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Video365Colors.secondaryBg,
        border: Border(
          top: BorderSide(color: Video365Colors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Trim
          _buildToolItem(
            label: 'Trim',
            isActive: editorState.activeTool == BottomTool.trim,
            onTap: () {
              editorNotifier.setBottomTool(BottomTool.trim);
              editorNotifier.splitSelectedClip();
            },
            iconType: Video365IconType.trim,
          ),

          // 2. Text
          _buildToolItem(
            label: 'Text',
            isActive: editorState.activeTool == BottomTool.text,
            onTap: () => editorNotifier.setBottomTool(BottomTool.text),
            iconType: Video365IconType.text,
          ),

          // 3. Audio
          _buildToolItem(
            label: 'Audio',
            isActive: editorState.activeTool == BottomTool.audio,
            onTap: () => editorNotifier.setBottomTool(BottomTool.audio),
            iconType: Video365IconType.audio,
          ),

          // 4. Filters
          _buildToolItem(
            label: 'Filters',
            isActive: editorState.activeTool == BottomTool.filters,
            onTap: () => editorNotifier.setBottomTool(BottomTool.filters),
            iconType: Video365IconType.filter,
          ),

          // 5. Effects
          _buildToolItem(
            label: 'Effects',
            isActive: editorState.activeTool == BottomTool.effects,
            onTap: () => editorNotifier.setBottomTool(BottomTool.effects),
            iconType: Video365IconType.effects,
          ),

          // 6. Speed
          _buildToolItem(
            label: 'Speed',
            isActive: editorState.activeTool == BottomTool.speed,
            onTap: () => editorNotifier.setBottomTool(BottomTool.speed),
            iconType: Video365IconType.speed,
          ),

          // 7. Auto Captions
          _buildToolItem(
            label: 'Captions',
            isActive: editorState.isCaptionsSheetOpen,
            onTap: () => editorNotifier.toggleCaptionsSheet(),
            iconFallback: Icons.subtitles_rounded,
          ),

          // 8. Radial Dial / Wheel Toggle
          _buildToolItem(
            label: 'Wheel',
            isActive: editorState.isRadialMenuOpen,
            onTap: () => editorNotifier.toggleRadialMenu(),
            iconType: Video365IconType.radialMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Video365IconType? iconType,
    IconData? iconFallback,
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
              child: iconType != null
                  ? Video365Icon(
                      iconType,
                      size: 20,
                      color: activeColor,
                    )
                  : Icon(
                      iconFallback ?? Icons.widgets_rounded,
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
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
