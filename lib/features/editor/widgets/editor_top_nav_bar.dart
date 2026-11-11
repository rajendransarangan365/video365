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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Back button (Matching Reference Image 1)
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Video365Colors.primaryText,
              ),
            ),
          ),

          // 2. Project Title with Tap to Rename (Matching Reference Image 1 "Untitle Project")
          GestureDetector(
            onTap: () {
              final textController = TextEditingController(text: editorState.project.name);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Video365Colors.panelBg,
                  title: const Text(
                    'Rename Project',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  content: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF11151D),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Video365Colors.secondaryText)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Video365Colors.activeGreen),
                      onPressed: () {
                        editorNotifier.renameProject(textController.text);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Save', style: TextStyle(color: Color(0xFF080A0E), fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editorState.project.name,
                  style: const TextStyle(
                    color: Video365Colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: Video365Colors.secondaryText,
                ),
              ],
            ),
          ),

          // 3. Export / Checkmark Action Button (Matching Reference Image 1)
          GestureDetector(
            onTap: () {
              editorNotifier.toggleExportSheet();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Video365Colors.activeGreen,
                borderRadius: BorderRadius.circular(19),
                boxShadow: [
                  BoxShadow(
                    color: Video365Colors.activeGreen.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Color(0xFF080A0E),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Export',
                    style: TextStyle(
                      color: Color(0xFF080A0E),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
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
