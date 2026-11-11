import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';

class EffectsDrawer extends ConsumerStatefulWidget {
  const EffectsDrawer({super.key});

  @override
  ConsumerState<EffectsDrawer> createState() => _EffectsDrawerState();
}

class _EffectsDrawerState extends ConsumerState<EffectsDrawer> {
  String _selectedEffect = 'retro_shake';
  double _intensity = 0.75;

  static const List<Map<String, dynamic>> _effects = [
    {
      'id': 'retro_shake',
      'name': 'Retro Shake 3',
      'category': 'Trending',
      'color': Color(0xFF06B6D4),
      'icon': Icons.vibration_rounded,
    },
    {
      'id': 'rgb_glitch',
      'name': 'RGB Split Glitch',
      'category': 'Trending',
      'color': Color(0xFFEC4899),
      'icon': Icons.blur_linear_rounded,
    },
    {
      'id': 'diamond_blur',
      'name': 'Diamond Zoom Blur',
      'category': 'Blur',
      'color': Color(0xFF3B82F6),
      'icon': Icons.center_focus_strong_rounded,
    },
    {
      'id': 'film_grain',
      'name': '16mm Film Grain',
      'category': 'Analog',
      'color': Color(0xFFF59E0B),
      'icon': Icons.grain_rounded,
    },
    {
      'id': 'vhs_1984',
      'name': 'VHS 1984 Scanline',
      'category': 'Analog',
      'color': Color(0xFF10B981),
      'icon': Icons.tv_rounded,
    },
    {
      'id': 'edge_glow',
      'name': 'Cyber Edge Glow',
      'category': 'Lighting',
      'color': Color(0xFF8B5CF6),
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      height: 270,
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
                  Icon(Icons.bolt_rounded, color: Video365Colors.activeGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Visual FX & Motion Shaders',
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

          const SizedBox(height: 10),

          // Effects Grid / Horizontal List
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _effects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final fx = _effects[index];
                final isSelected = _selectedEffect == fx['id'];
                final fxColor = fx['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEffect = fx['id'] as String);
                    editorNotifier.addEffectLayer(
                      fx['id'] as String,
                      title: fx['name'] as String,
                      intensity: _intensity,
                    );
                  },
                  child: Container(
                    width: 105,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E2838) : Video365Colors.panelBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Video365Colors.activeGreen : Video365Colors.cardBorder,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Video365Colors.activeGreen.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(fx['icon'] as IconData, size: 26, color: fxColor),
                        const SizedBox(height: 6),
                        Text(
                          fx['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Video365Colors.primaryText,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Intensity Slider
          Row(
            children: [
              const Text(
                'Intensity',
                style: TextStyle(
                  color: Video365Colors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Video365Colors.activeGreen,
                    inactiveTrackColor: const Color(0xFF283244),
                    thumbColor: Colors.white,
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _intensity,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (val) {
                      setState(() => _intensity = val);
                      editorNotifier.addEffectLayer(
                        _selectedEffect,
                        intensity: val,
                      );
                    },
                  ),
                ),
              ),
              Text(
                '${(_intensity * 100).toInt()}%',
                style: const TextStyle(
                  color: Video365Colors.activeGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),

          // Add / Remove Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  editorNotifier.addEffectLayer('none', intensity: 0);
                  editorNotifier.closeActiveDrawer();
                },
                child: const Text(
                  'Remove FX',
                  style: TextStyle(color: Video365Colors.secondaryText, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Video365Colors.activeGreen,
                  foregroundColor: const Color(0xFF080A0E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => editorNotifier.closeActiveDrawer(),
                child: const Text('Apply FX', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

