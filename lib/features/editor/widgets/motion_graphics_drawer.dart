import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';

class MotionGraphicsDrawer extends ConsumerStatefulWidget {
  const MotionGraphicsDrawer({super.key});

  @override
  ConsumerState<MotionGraphicsDrawer> createState() => _MotionGraphicsDrawerState();
}

class _MotionGraphicsDrawerState extends ConsumerState<MotionGraphicsDrawer> {
  final TextEditingController _titleController =
      TextEditingController(text: 'SARANGAN RAJENDRAN');
  final TextEditingController _subtitleController =
      TextEditingController(text: 'DIRECTOR & MOTION DESIGNER');

  String _selectedTemplate = 'lower_third_minimal';
  Color _accentColor = Video365Colors.activeGreen;
  double _fontSize = 26.0;

  static const List<Map<String, dynamic>> _templates = [
    {
      'id': 'lower_third_minimal',
      'name': 'Minimal Accent Bar',
      'desc': 'Clean line + tracking subtitle',
      'icon': Icons.subtitles_rounded,
    },
    {
      'id': 'cyber_tag',
      'name': 'Cyberpunk Neon Tag',
      'desc': 'Glowing tech framed badge',
      'icon': Icons.developer_board_rounded,
    },
    {
      'id': 'broadcast_ribbon',
      'name': 'Broadcast Lower Third',
      'desc': 'High-impact double ribbon',
      'icon': Icons.view_headline_rounded,
    },
    {
      'id': 'kinetic_punch',
      'name': 'Kinetic 3D Punch',
      'desc': 'Bold uppercase pop typography',
      'icon': Icons.format_size_rounded,
    },
  ];

  static const List<Color> _swatches = [
    Video365Colors.activeGreen,
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF59E0B), // Gold
    Color(0xFFEC4899), // Pink
    Color(0xFF3B82F6), // Blue
    Colors.white,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _applyGraphic() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    ref.read(editorProvider.notifier).addMotionGraphicsTitle(
          title: title,
          subtitle: _subtitleController.text.trim(),
          type: _selectedTemplate,
          color: _accentColor,
          fontSize: _fontSize,
        );

    ref.read(editorProvider.notifier).closeActiveDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      height: 360,
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
          // Drawer Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.title_rounded, color: Video365Colors.activeGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Motion Graphics & Lower Thirds (After Effects / JSX)',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 14,
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

          const SizedBox(height: 10),

          // Template Selector
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _templates[index];
                final isSelected = _selectedTemplate == item['id'];

                return GestureDetector(
                  onTap: () => setState(() => _selectedTemplate = item['id'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E2838) : Video365Colors.panelBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Video365Colors.activeGreen : Video365Colors.cardBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Video365Colors.activeGreen : Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['name'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Video365Colors.primaryText,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              item['desc'] as String,
                              style: const TextStyle(
                                color: Video365Colors.secondaryText,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Title & Subtitle Input Fields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Main Title',
                    labelStyle: const TextStyle(color: Video365Colors.secondaryText, fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF131722),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _subtitleController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Subtitle / Role',
                    labelStyle: const TextStyle(color: Video365Colors.secondaryText, fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF131722),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Accent Color Swatches & Font Size
          Row(
            children: [
              const Text(
                'Color:',
                style: TextStyle(color: Video365Colors.secondaryText, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              ..._swatches.map((c) {
                final isSelected = _accentColor == c;
                return GestureDetector(
                  onTap: () => setState(() => _accentColor = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Text(
                'Size: ${_fontSize.toInt()}pt',
                style: const TextStyle(color: Video365Colors.secondaryText, fontSize: 11),
              ),
            ],
          ),

          const Spacer(),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Video365Colors.activeGreen,
                foregroundColor: const Color(0xFF080A0E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              ),
              onPressed: _applyGraphic,
              child: const Text(
                'Insert Motion Graphic Layer',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
