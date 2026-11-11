import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';

class MotionGraphicsDrawer extends ConsumerStatefulWidget {
  const MotionGraphicsDrawer({super.key});

  @override
  ConsumerState<MotionGraphicsDrawer> createState() => _MotionGraphicsDrawerState();
}

class _MotionGraphicsDrawerState extends ConsumerState<MotionGraphicsDrawer> {
  int _activeTab = 0; // 0 = Transform & Keyframes, 1 = Titles & Lower Thirds
  String _selectedEasing = 'easeInOut';

  // Titles Tab Controllers
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
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final selectedClip = editorState.selectedClip;

    return Container(
      height: 380,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Icon(Icons.animation_rounded, color: Video365Colors.activeGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Motion & Keyframing (VectorCraft / After Effects)',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 13.5,
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

          const SizedBox(height: 6),

          // Tab Selector: Transform / Keyframes vs Motion Titles
          Container(
            height: 34,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Video365Colors.panelBg,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? Video365Colors.activeGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Transform & Keyframes',
                        style: TextStyle(
                          color: _activeTab == 0 ? const Color(0xFF080A0E) : Video365Colors.secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? Video365Colors.activeGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Lower Thirds & Titles',
                        style: TextStyle(
                          color: _activeTab == 1 ? const Color(0xFF080A0E) : Video365Colors.secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Content based on tab
          Expanded(
            child: _activeTab == 0
                ? _buildKeyframingView(selectedClip, editorNotifier, editorState)
                : _buildTitlesView(),
          ),
        ],
      ),
    );
  }

  // ─── Keyframing & Transform View (VectorCraft / AE GPU Model) ────────────────
  Widget _buildKeyframingView(ClipItem? clip, EditorNotifier notifier, EditorState editorState) {
    if (clip == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.touch_app_rounded, size: 36, color: Video365Colors.secondaryText),
            SizedBox(height: 8),
            Text(
              'Select a clip on the timeline to animate and add keyframes',
              style: TextStyle(color: Video365Colors.secondaryText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final relMs = (editorState.currentTimeMs - clip.startMs).clamp(0.0, clip.durationMs);
    final curScale = clip.evaluateProperty(KeyframeProperty.scale, relMs, clip.scale);
    final curOpacity = clip.evaluateProperty(KeyframeProperty.opacity, relMs, clip.opacity);
    final curRot = clip.evaluateProperty(KeyframeProperty.rotation, relMs, clip.rotation);
    final curPosX = clip.evaluateProperty(KeyframeProperty.positionX, relMs, clip.position.dx);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Easing Selector Pill
          Row(
            children: [
              const Text(
                'Easing Curve:',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              ...['linear', 'easeIn', 'easeOut', 'easeInOut'].map((e) {
                final isSel = _selectedEasing == e;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(e, style: TextStyle(fontSize: 10, color: isSel ? Colors.black : Colors.white)),
                    selected: isSel,
                    selectedColor: Video365Colors.activeGreen,
                    backgroundColor: const Color(0xFF131722),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    onSelected: (val) {
                      if (val) setState(() => _selectedEasing = e);
                    },
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 8),

          // 1. Scale Slider + Diamond Keyframe Button
          _buildPropertyRow(
            label: 'Scale',
            valueStr: '${curScale.toStringAsFixed(2)}x',
            sliderValue: curScale.clamp(0.2, 3.0),
            min: 0.2,
            max: 3.0,
            onChanged: (val) {
              notifier.updateClip(clip.id, (c) => c.copyWith(scale: val));
            },
            onAddKeyframe: () {
              notifier.addOrUpdateKeyframe(clip.id, KeyframeProperty.scale, curScale, easing: _selectedEasing);
              HapticFeedback.selectionClick();
              _showKeyframeSnackbar('Scale');
            },
          ),

          // 2. Opacity Slider + Diamond Keyframe Button
          _buildPropertyRow(
            label: 'Opacity',
            valueStr: '${(curOpacity * 100).toInt()}%',
            sliderValue: curOpacity.clamp(0.0, 1.0),
            min: 0.0,
            max: 1.0,
            onChanged: (val) {
              notifier.updateClip(clip.id, (c) => c.copyWith(opacity: val));
            },
            onAddKeyframe: () {
              notifier.addOrUpdateKeyframe(clip.id, KeyframeProperty.opacity, curOpacity, easing: _selectedEasing);
              HapticFeedback.selectionClick();
              _showKeyframeSnackbar('Opacity');
            },
          ),

          // 3. Rotation Slider + Diamond Keyframe Button
          _buildPropertyRow(
            label: 'Rotation',
            valueStr: '${curRot.toInt()}°',
            sliderValue: curRot.clamp(-180.0, 180.0),
            min: -180.0,
            max: 180.0,
            onChanged: (val) {
              notifier.updateClip(clip.id, (c) => c.copyWith(rotation: val));
            },
            onAddKeyframe: () {
              notifier.addOrUpdateKeyframe(clip.id, KeyframeProperty.rotation, curRot, easing: _selectedEasing);
              HapticFeedback.selectionClick();
              _showKeyframeSnackbar('Rotation');
            },
          ),

          // 4. Position X Slider + Diamond Keyframe Button
          _buildPropertyRow(
            label: 'Position X',
            valueStr: '${curPosX.toInt()}px',
            sliderValue: curPosX.clamp(-200.0, 200.0),
            min: -200.0,
            max: 200.0,
            onChanged: (val) {
              notifier.updateClip(clip.id, (c) => c.copyWith(position: Offset(val, c.position.dy)));
            },
            onAddKeyframe: () {
              notifier.addOrUpdateKeyframe(clip.id, KeyframeProperty.positionX, curPosX, easing: _selectedEasing);
              HapticFeedback.selectionClick();
              _showKeyframeSnackbar('Position X');
            },
          ),

          const SizedBox(height: 8),

          // Keyframe Diamonds List for Current Clip
          if (clip.keyframes.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Keyframes (${clip.keyframes.length}):',
                  style: const TextStyle(color: Video365Colors.primaryText, fontSize: 11, fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () {
                    for (final k in List<Keyframe>.from(clip.keyframes)) {
                      notifier.removeKeyframe(clip.id, k);
                    }
                  },
                  child: const Text('Clear All', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: clip.keyframes.map((k) {
                return Chip(
                  avatar: const Icon(Icons.diamond_rounded, size: 12, color: Video365Colors.activeGreen),
                  label: Text(
                    '${(k.timeMs / 1000).toStringAsFixed(1)}s: ${k.property.label} = ${k.value.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 9.5, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF131722),
                  deleteIcon: const Icon(Icons.close, size: 12, color: Colors.white60),
                  onDeleted: () => notifier.removeKeyframe(clip.id, k),
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showKeyframeSnackbar(String prop) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $prop keyframe at playhead!'),
        duration: const Duration(milliseconds: 900),
        backgroundColor: Video365Colors.activeGreen,
      ),
    );
  }

  Widget _buildPropertyRow({
    required String label,
    required String valueStr,
    required double sliderValue,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required VoidCallback onAddKeyframe,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              valueStr,
              style: const TextStyle(color: Video365Colors.activeGreen, fontSize: 10, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Video365Colors.activeGreen,
                inactiveTrackColor: const Color(0xFF222B3D),
                thumbColor: Colors.white,
                trackHeight: 2.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: sliderValue,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.diamond_outlined, color: Video365Colors.activeGreen, size: 18),
            tooltip: 'Add Keyframe',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onAddKeyframe,
          ),
        ],
      ),
    );
  }

  // ─── Titles & Lower Thirds View ──────────────────────────────────────────────
  Widget _buildTitlesView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template Selector
          SizedBox(
            height: 52,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          size: 15,
                          color: isSelected ? Video365Colors.activeGreen : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['name'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Video365Colors.primaryText,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              item['desc'] as String,
                              style: const TextStyle(
                                color: Video365Colors.secondaryText,
                                fontSize: 8.5,
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

          const SizedBox(height: 10),

          // Title & Subtitle Input Fields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  decoration: InputDecoration(
                    labelText: 'Main Title',
                    labelStyle: const TextStyle(color: Video365Colors.secondaryText, fontSize: 10),
                    filled: true,
                    fillColor: const Color(0xFF131722),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _subtitleController,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  decoration: InputDecoration(
                    labelText: 'Subtitle / Role',
                    labelStyle: const TextStyle(color: Video365Colors.secondaryText, fontSize: 10),
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

          const SizedBox(height: 10),

          // Color Swatches
          Row(
            children: [
              const Text(
                'Color:',
                style: TextStyle(color: Video365Colors.secondaryText, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              ..._swatches.map((c) {
                final isSelected = _accentColor == c;
                return GestureDetector(
                  onTap: () => setState(() => _accentColor = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 20,
                    height: 20,
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
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Video365Colors.activeGreen,
                foregroundColor: const Color(0xFF080A0E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _applyGraphic,
              child: const Text(
                'Insert Motion Graphic Layer',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
