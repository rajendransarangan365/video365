import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';

class FiltersDrawer extends ConsumerStatefulWidget {
  const FiltersDrawer({super.key});

  @override
  ConsumerState<FiltersDrawer> createState() => _FiltersDrawerState();
}

class _FiltersDrawerState extends ConsumerState<FiltersDrawer> {
  String _selectedFilter = 'teal_orange';
  double _intensity = 0.8;

  static const List<Map<String, dynamic>> _filters = [
    {
      'id': 'none',
      'name': 'Original / Clean',
      'colors': [Color(0xFF64748B), Color(0xFF334155)],
    },
    {
      'id': 'teal_orange',
      'name': 'Teal & Orange',
      'colors': [Color(0xFF0D9488), Color(0xFFEA580C)],
    },
    {
      'id': 'moody_dark',
      'name': 'Moody Dark Noir',
      'colors': [Color(0xFF1E293B), Color(0xFF0F172A)],
    },
    {
      'id': 'cyberpunk',
      'name': 'Cyberpunk Neon',
      'colors': [Color(0xFF06B6D4), Color(0xFFD946EF)],
    },
    {
      'id': 'golden_hour',
      'name': 'Golden Sunset',
      'colors': [Color(0xFFF59E0B), Color(0xFFB45309)],
    },
    {
      'id': 'noir',
      'name': 'Monochrome B&W',
      'colors': [Color(0xFFE2E8F0), Color(0xFF1E293B)],
    },
    {
      'id': 'vintage',
      'name': 'Vintage 1970 Film',
      'colors': [Color(0xFF84CC16), Color(0xFF78350F)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      height: 260,
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
                  Icon(Icons.tune_rounded, color: Video365Colors.activeGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Color Grading & 3D LUT Presets',
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

          // Filters Horizontal List
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['id'];
                final colors = filter['colors'] as List<Color>;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = filter['id'] as String);
                    editorNotifier.applyFilterPreset(
                      filter['id'] as String,
                      _intensity,
                    );
                  },
                  child: Container(
                    width: 100,
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
                        // Gradient preview swatch
                        Container(
                          width: 32,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          filter['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Video365Colors.primaryText,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 1,
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
                      editorNotifier.applyFilterPreset(_selectedFilter, val);
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

          // Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  editorNotifier.applyFilterPreset('none', 0.0);
                  editorNotifier.closeActiveDrawer();
                },
                child: const Text('Reset', style: TextStyle(color: Video365Colors.secondaryText, fontSize: 12)),
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
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

