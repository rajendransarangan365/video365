import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';

class RadialEditingMenu extends ConsumerStatefulWidget {
  const RadialEditingMenu({super.key});

  @override
  ConsumerState<RadialEditingMenu> createState() => _RadialEditingMenuState();
}

class _RadialEditingMenuState extends ConsumerState<RadialEditingMenu> {
  int _selectedIndex = 0;
  double _rotationAngle = 0.0;

  static const List<Map<String, dynamic>> _radialTools = [
    {
      'label': 'Trim',
      'icon': Icons.content_cut_rounded,
      'tool': BottomTool.trim,
    },
    {
      'label': 'Text',
      'icon': Icons.description_outlined,
      'tool': BottomTool.text,
    },
    {
      'label': 'Audio',
      'icon': Icons.music_note_rounded,
      'tool': BottomTool.audio,
    },
    {
      'label': 'Color',
      'icon': Icons.tune_rounded,
      'tool': BottomTool.filters,
    },
    {
      'label': 'Voice',
      'icon': Icons.mic_rounded,
      'tool': BottomTool.audio,
    },
    {
      'label': 'Speed',
      'icon': Icons.timer_outlined,
      'tool': BottomTool.speed,
    },
    {
      'label': 'Effects',
      'icon': Icons.bolt_rounded,
      'tool': BottomTool.effects,
    },
    {
      'label': 'Media',
      'icon': Icons.image_outlined,
      'tool': BottomTool.trim,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final editorNotifier = ref.read(editorProvider.notifier);
    final activeToolData = _radialTools[_selectedIndex];

    const wheelDiameter = 280.0;
    const ringRadius = wheelDiameter / 2;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => editorNotifier.toggleRadialMenu(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withOpacity(0.75),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 40),
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping inside the wheel
            onPanUpdate: (details) {
              setState(() {
                _rotationAngle += details.delta.dx * 0.01;
                // Normalize index based on rotation angle
                final normalized = (-_rotationAngle / (2 * math.pi / _radialTools.length)).round();
                _selectedIndex = (normalized % _radialTools.length + _radialTools.length) % _radialTools.length;
              });
            },
            child: SizedBox(
              width: wheelDiameter + 60,
              height: wheelDiameter + 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer concentric decorative rings
                  Container(
                    width: wheelDiameter,
                    height: wheelDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1E2638).withOpacity(0.9),
                          const Color(0xFF11151D).withOpacity(0.95),
                          const Color(0xFF080A0E),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF293244),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // Inner concentric guide circle
                  Container(
                    width: wheelDiameter * 0.58,
                    height: wheelDiameter * 0.58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF232A38),
                        width: 1,
                      ),
                    ),
                  ),

                  // 8 Orbiting Tool Nodes
                  ...List.generate(_radialTools.length, (index) {
                    final item = _radialTools[index];
                    final isCurrent = index == _selectedIndex;

                    // Angle around the circle (index 0 at top: -pi/2)
                    final baseAngle = (index * 2 * math.pi / _radialTools.length) - (math.pi / 2);
                    final effectiveAngle = baseAngle + _rotationAngle;

                    final nodeX = math.cos(effectiveAngle) * (ringRadius - 32);
                    final nodeY = math.sin(effectiveAngle) * (ringRadius - 32);

                    return Transform.translate(
                      offset: Offset(nodeX, nodeY),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          editorNotifier.setBottomTool(item['tool'] as BottomTool);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? Video365Colors.activeGreen
                                : const Color(0xFF1A212E),
                            border: Border.all(
                              color: isCurrent
                                  ? Colors.white
                                  : const Color(0xFF2E394E),
                              width: isCurrent ? 2 : 1,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: Video365Colors.activeGreen.withOpacity(0.5),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isCurrent ? Colors.black : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Center Circular Action Dial
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F131C),
                      border: Border.all(
                        color: const Color(0xFF252D3D),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          activeToolData['icon'] as IconData,
                          size: 24,
                          color: Video365Colors.activeGreen,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeToolData['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'rotate to switch',
                          style: TextStyle(
                            color: Video365Colors.secondaryText,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
