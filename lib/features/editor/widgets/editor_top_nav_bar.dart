import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../core/widgets/video365_icons.dart';
import '../../../providers/editor_provider.dart';

class EditorTopNavBar extends ConsumerWidget {
  final VoidCallback? onBack;

  const EditorTopNavBar({super.key, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Video365Colors.mainBg,
      ),
      child: Row(
        children: [
          // Close / Back button
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Video365Icon(
                Video365IconType.close,
                size: 18,
                color: Video365Colors.primaryText,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Undo / Redo controls pill
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Video365Colors.panelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Video365Colors.cardBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo_rounded, size: 20, color: Video365Colors.primaryText),
                  onPressed: () {},
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: Video365Colors.cardBorder,
                ),
                IconButton(
                  icon: const Icon(Icons.redo_rounded, size: 20, color: Video365Colors.secondaryText),
                  onPressed: () {},
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Project Title
          Text(
            editorState.project.name,
            style: const TextStyle(
              color: Video365Colors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // Vibrant Green [ ↑ Export ] Button (matching Screenshot 4 Screen 1)
          GestureDetector(
            onTap: () {
              editorNotifier.toggleExportSheet();
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Video365Colors.activeGreen,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Video365Colors.activeGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Video365Icon(
                    Video365IconType.export,
                    size: 14,
                    color: Color(0xFF080A0E),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Export',
                    style: TextStyle(
                      color: Color(0xFF080A0E),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
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
