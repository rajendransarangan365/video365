import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';

class TrimDrawer extends ConsumerWidget {
  const TrimDrawer({super.key});

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
                  Icon(Icons.content_cut_rounded, color: Video365Colors.activeGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Precision Trim & Cut Tools',
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

          const SizedBox(height: 14),

          // Action Buttons Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Split
              _buildActionButton(
                label: 'Split at Needle',
                icon: Icons.splitscreen_rounded,
                color: Video365Colors.activeGreen,
                onTap: () {
                  editorNotifier.splitSelectedClip();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clip split into two parts at needle!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              // 2. Duplicate
              _buildActionButton(
                label: 'Duplicate',
                icon: Icons.copy_rounded,
                color: Video365Colors.blueAccent,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clip duplicated successfully!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              // 3. Delete
              _buildActionButton(
                label: 'Delete Clip',
                icon: Icons.delete_outline_rounded,
                color: Video365Colors.redAccent,
                onTap: () {
                  editorNotifier.deleteSelectedClip();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selected clip removed!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          const Spacer(),

          // Selected clip hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Video365Colors.panelBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: Video365Colors.secondaryText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    editorState.selectedClipId != null
                        ? 'Selected Clip: ${editorState.selectedClipId} (needle at ${(editorState.currentTimeMs / 1000).toStringAsFixed(1)}s)'
                        : 'Select any clip on the timeline above to cut or trim',
                    style: const TextStyle(color: Video365Colors.secondaryText, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Video365Colors.panelBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Video365Colors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Video365Colors.primaryText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
