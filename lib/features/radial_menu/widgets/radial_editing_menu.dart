import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';
import '../../../services/permission_service.dart';

class RadialEditingMenu extends ConsumerStatefulWidget {
  const RadialEditingMenu({super.key});

  @override
  ConsumerState<RadialEditingMenu> createState() => _RadialEditingMenuState();
}

class _RadialEditingMenuState extends ConsumerState<RadialEditingMenu> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  double _rotationAngle = 0.0;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  static const List<Map<String, dynamic>> _radialTools = [
    {
      'label': 'Trim & Split',
      'icon': Icons.content_cut_rounded,
      'tool': BottomTool.trim,
      'action': 'trim',
    },
    {
      'label': 'Text & Titles',
      'icon': Icons.title_rounded,
      'tool': BottomTool.text,
      'action': 'text',
    },
    {
      'label': 'Music Audio',
      'icon': Icons.music_note_rounded,
      'tool': BottomTool.audio,
      'action': 'audio',
    },
    {
      'label': 'Color LUTs',
      'icon': Icons.tune_rounded,
      'tool': BottomTool.filters,
      'action': 'color',
    },
    {
      'label': 'Voiceover',
      'icon': Icons.mic_rounded,
      'tool': BottomTool.none,
      'action': 'voice',
    },
    {
      'label': 'Speed Curve',
      'icon': Icons.speed_rounded,
      'tool': BottomTool.speed,
      'action': 'speed',
    },
    {
      'label': 'FX Layers',
      'icon': Icons.auto_fix_high_rounded,
      'tool': BottomTool.effects,
      'action': 'effects',
    },
    {
      'label': 'Add Media',
      'icon': Icons.add_photo_alternate_outlined,
      'tool': BottomTool.media,
      'action': 'media',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _executeToolAction(Map<String, dynamic> toolItem) {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(editorProvider.notifier);
    final action = toolItem['action'] as String;

    // Close the radial wheel first
    notifier.toggleRadialMenu();

    switch (action) {
      case 'trim':
        notifier.setBottomTool(BottomTool.trim);
        break;
      case 'text':
        notifier.setBottomTool(BottomTool.text);
        break;
      case 'audio':
        notifier.toggleMediaBrowser();
        break;
      case 'color':
        notifier.setBottomTool(BottomTool.filters);
        break;
      case 'voice':
        PermissionService.requestMicrophone().then((granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                granted ? 'Microphone ready for Voiceover recording' : 'Microphone permission denied',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: granted ? Video365Colors.activeGreen : const Color(0xFFEF5350),
            ),
          );
        });
        break;
      case 'speed':
        notifier.setBottomTool(BottomTool.speed);
        break;
      case 'effects':
        notifier.setBottomTool(BottomTool.effects);
        break;
      case 'media':
        notifier.toggleMediaBrowser();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeToolData = _radialTools[_selectedIndex];
    const wheelDiameter = 280.0;
    const ringRadius = wheelDiameter / 2;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          ref.read(editorProvider.notifier).toggleRadialMenu();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withValues(alpha: 0.70),
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () {}, // Prevent dismissal when tapping inside
              onPanUpdate: (details) {
                setState(() {
                  _rotationAngle += details.delta.dx * 0.012;
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
                    // Outer Ring Glow
                    Container(
                      width: wheelDiameter,
                      height: wheelDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF1E2638).withValues(alpha: 0.95),
                            const Color(0xFF11151D).withValues(alpha: 0.98),
                            const Color(0xFF080A0E),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFF293244),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    // Inner concentric circle guide
                    Container(
                      width: wheelDiameter * 0.58,
                      height: wheelDiameter * 0.58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF232A38),
                          width: 1.2,
                        ),
                      ),
                    ),

                    // 8 Orbiting Tool Nodes
                    ...List.generate(_radialTools.length, (index) {
                      final item = _radialTools[index];
                      final isCurrent = index == _selectedIndex;

                      final baseAngle = (index * 2 * math.pi / _radialTools.length) - (math.pi / 2);
                      final effectiveAngle = baseAngle + _rotationAngle;

                      final nodeX = math.cos(effectiveAngle) * (ringRadius - 32);
                      final nodeY = math.sin(effectiveAngle) * (ringRadius - 32);

                      return Transform.translate(
                        offset: Offset(nodeX, nodeY),
                        child: GestureDetector(
                          onTap: () => _executeToolAction(item),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: isCurrent ? 48 : 42,
                            height: isCurrent ? 48 : 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? Video365Colors.activeGreen
                                  : const Color(0xFF1A212E),
                              border: Border.all(
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF2E394E),
                                width: isCurrent ? 2.5 : 1,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: Video365Colors.activeGreen.withValues(alpha: 0.6),
                                        blurRadius: 16,
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              item['icon'] as IconData,
                              size: isCurrent ? 22 : 18,
                              color: isCurrent ? Colors.black : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }),

                    // Center Interactive Action Dial (Tap to Execute!)
                    GestureDetector(
                      onTap: () => _executeToolAction(activeToolData),
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F131C),
                          border: Border.all(
                            color: Video365Colors.activeGreen,
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Video365Colors.activeGreen.withValues(alpha: 0.35),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              activeToolData['icon'] as IconData,
                              size: 26,
                              color: Video365Colors.activeGreen,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeToolData['label'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'tap to open',
                              style: TextStyle(
                                color: Video365Colors.activeGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
