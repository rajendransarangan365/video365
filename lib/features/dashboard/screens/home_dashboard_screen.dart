import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';
import '../../editor/screens/editor_screen.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _selectedTab = 0; // 0 = Studio, 1 = Quick Edit

  void _openEditor(BuildContext context, {Video365Project? project}) {
    if (project != null) {
      ref.read(editorProvider.notifier).loadProject(project);
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditorScreen(),
      ),
    );
  }

  void _showNewProjectDialog(BuildContext context) {
    String projectName = 'Untitled Project ${DateTime.now().millisecond}';
    AspectRatioType selectedAspect = AspectRatioType.ratio9_16;
    ResolutionType selectedResolution = ResolutionType.res1080p;
    FrameRateType selectedFps = FrameRateType.fps30;

    showModalBottomSheet(
      context: context,
      backgroundColor: Video365Colors.panelBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Project',
                        style: TextStyle(
                          color: Video365Colors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Video365Colors.secondaryText),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Project Name TextField
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                      labelStyle: const TextStyle(color: Video365Colors.secondaryText),
                      filled: true,
                      fillColor: const Color(0xFF131722),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Video365Colors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Video365Colors.activeGreen),
                      ),
                    ),
                    onChanged: (val) => projectName = val,
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Aspect Ratio',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Aspect Ratio Selector Chips
                  Wrap(
                    spacing: 8,
                    children: AspectRatioType.values.map((aspect) {
                      final isSelected = selectedAspect == aspect;
                      return ChoiceChip(
                        label: Text(aspect.label),
                        selected: isSelected,
                        selectedColor: Video365Colors.activeGreen,
                        backgroundColor: const Color(0xFF131722),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedAspect = aspect);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Create Project CTA
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Video365Colors.activeGreen,
                        foregroundColor: const Color(0xFF080A0E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        final newProject = Video365Project(
                          id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                          name: projectName.trim().isEmpty ? 'New Project' : projectName.trim(),
                          createdAt: DateTime.now(),
                          modifiedAt: DateTime.now(),
                          aspectRatio: selectedAspect,
                          resolution: selectedResolution,
                          fps: selectedFps,
                        );
                        _openEditor(context, project: newProject);
                      },
                      child: const Text(
                        'Create & Open Studio',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);

    return Scaffold(
      backgroundColor: Video365Colors.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Dashboard Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Video365 Logo Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: Video365Colors.greenGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Video365Colors.activeGreen.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Video365',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Video365Colors.primaryText),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Video365Colors.primaryText),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Mode Switcher: Studio Edit vs Quick Edit
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Video365Colors.panelBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Video365Colors.cardBorder, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? Video365Colors.activeGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Studio Edit',
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? const Color(0xFF080A0E)
                                : Video365Colors.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? Video365Colors.activeGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Quick Edit',
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? const Color(0xFF080A0E)
                                : Video365Colors.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Start New Project Hero Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2638), Color(0xFF11151D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A3448), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Create New Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Multi-track timeline, 4K HDR, and After Effects motion graphics',
                          style: TextStyle(
                            color: Video365Colors.secondaryText,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Video365Colors.activeGreen,
                      foregroundColor: const Color(0xFF080A0E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () => _showNewProjectDialog(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_rounded, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'New',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Projects Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recent Projects',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                      color: Video365Colors.activeGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Projects List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Preloaded Master Project matching screenshot
                  _ProjectCard(
                    title: editorState.project.name,
                    aspect: editorState.project.aspectRatio.label,
                    duration: '0:14',
                    resolution: '1080p · 30fps',
                    modified: 'Just now',
                    badgeColor: Video365Colors.activeGreen,
                    onTap: () => _openEditor(context),
                  ),

                  _ProjectCard(
                    title: 'Summer Vibes 4K',
                    aspect: '16:9',
                    duration: '0:28',
                    resolution: '4K · 60fps',
                    modified: '2 hours ago',
                    badgeColor: Video365Colors.blueAccent,
                    onTap: () {
                      final p = editorState.project.copyWith(
                        id: 'proj_summer_4k',
                        name: 'Summer Vibes 4K',
                        aspectRatio: AspectRatioType.ratio16_9,
                        resolution: ResolutionType.res4K,
                        fps: FrameRateType.fps60,
                      );
                      _openEditor(context, project: p);
                    },
                  ),

                  _ProjectCard(
                    title: 'Tokyo Street Motion',
                    aspect: '9:16',
                    duration: '0:19',
                    resolution: '1080p · 60fps',
                    modified: 'Yesterday',
                    badgeColor: Video365Colors.purpleAccent,
                    onTap: () {
                      final p = editorState.project.copyWith(
                        id: 'proj_tokyo',
                        name: 'Tokyo Street Motion',
                        aspectRatio: AspectRatioType.ratio9_16,
                      );
                      _openEditor(context, project: p);
                    },
                  ),

                  // Open Source & Community Support Card
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Video365Colors.panelBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Video365Colors.cardBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.code_rounded, color: Video365Colors.activeGreen, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Video365 Open Source',
                              style: TextStyle(
                                color: Video365Colors.primaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Empowering creators worldwide with professional, private, local video editing.',
                          style: TextStyle(
                            color: Video365Colors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF232A38),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Star on GitHub',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF232A38),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.volunteer_activism_rounded, color: Color(0xFFEC4899), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Sponsor Project',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String title;
  final String aspect;
  final String duration;
  final String resolution;
  final String modified;
  final Color badgeColor;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.title,
    required this.aspect,
    required this.duration,
    required this.resolution,
    required this.modified,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Video365Colors.panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Video365Colors.cardBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Project Thumbnail
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131722),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF232A38), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.movie_outlined, color: Colors.white.withOpacity(0.4), size: 24),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Project Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Video365Colors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              aspect,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            resolution,
                            style: const TextStyle(
                              color: Video365Colors.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            modified,
                            style: const TextStyle(
                              color: Video365Colors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Video365Colors.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
