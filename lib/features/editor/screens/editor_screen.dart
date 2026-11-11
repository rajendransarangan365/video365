import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';
import '../../captions/widgets/auto_captions_sheet.dart';
import '../../export/widgets/export_modal_sheet.dart';
import '../../radial_menu/widgets/radial_editing_menu.dart';
import '../widgets/add_track_sheet.dart';
import '../widgets/bottom_tool_bar.dart';
import '../widgets/editor_top_nav_bar.dart';
import '../widgets/effects_drawer.dart';
import '../widgets/filters_drawer.dart';
import '../widgets/media_import_sheet.dart';
import '../widgets/motion_graphics_drawer.dart';
import '../widgets/multi_track_timeline.dart';
import '../widgets/speed_drawer.dart';
import '../widgets/trim_drawer.dart';
import '../widgets/video_preview_card.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Video365Colors.mainBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Base Studio Layout
            Column(
              children: [
                // 1. Top Navigation Bar: [< Back] [Untitle Project ✎] [✓ Export]
                const EditorTopNavBar(),

                // 2. Responsive Work Area (Portrait Phone vs Landscape/Tablet Studio)
                Expanded(
                  child: (isLandscape || isTablet)
                      ? Row(
                          children: [
                            // Left Pane: Video Preview Monitor with Floating Controls
                            const SizedBox(
                              width: 380,
                              child: VideoPreviewCard(),
                            ),
                            // Right Pane: Multi-Track Timeline & Context Panels
                            Expanded(
                              child: Column(
                                children: [
                                  const Expanded(child: MultiTrackTimeline()),
                                  if (editorState.activeTool == BottomTool.effects)
                                    const EffectsDrawer()
                                  else if (editorState.activeTool == BottomTool.filters)
                                    const FiltersDrawer()
                                  else if (editorState.activeTool == BottomTool.text)
                                    const MotionGraphicsDrawer()
                                  else if (editorState.activeTool == BottomTool.speed)
                                    const SpeedDrawer()
                                  else if (editorState.activeTool == BottomTool.trim)
                                    const TrimDrawer(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            // Top: Video Preview Card with Floating Glass Controls
                            const VideoPreviewCard(),

                            // Center: Multi-Track Timeline with In-Sync Needle & Zoom Controls
                            const Expanded(
                              child: MultiTrackTimeline(),
                            ),

                            // Bottom: Contextual Active Tool Drawer (if open)
                            if (editorState.activeTool == BottomTool.effects)
                              const EffectsDrawer()
                            else if (editorState.activeTool == BottomTool.filters)
                              const FiltersDrawer()
                            else if (editorState.activeTool == BottomTool.text)
                              const MotionGraphicsDrawer()
                            else if (editorState.activeTool == BottomTool.speed)
                              const SpeedDrawer()
                            else if (editorState.activeTool == BottomTool.trim)
                              const TrimDrawer(),
                          ],
                        ),
                ),

                // 3. Bottom Toolbar (Text, Music, Stickers, Split, Filter, Effects, Speed, Captions, Wheel, Media)
                const BottomToolBar(),
              ],
            ),

            // Floating Radial Wheel FAB (Click to expand radial menu)
            if (!editorState.isRadialMenuOpen && !editorState.isCaptionsSheetOpen && !editorState.isExportSheetOpen)
              Positioned(
                right: 14,
                bottom: 80,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    ref.read(editorProvider.notifier).toggleRadialMenu();
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131722),
                      shape: BoxShape.circle,
                      border: Border.all(color: Video365Colors.activeGreen, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Video365Colors.activeGreen.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        const BoxShadow(
                          color: Colors.black87,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.album_outlined,
                        color: Video365Colors.activeGreen,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

            // Modal Layer 1: Media Import Sheet
            if (editorState.isMediaBrowserOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => ref.read(editorProvider.notifier).toggleMediaBrowser(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {},
                      child: const MediaImportSheet(),
                    ),
                  ),
                ),
              ),

            // Modal Layer 1.5: Add Track Sheet
            if (editorState.isAddTrackSheetOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => ref.read(editorProvider.notifier).toggleAddTrackSheet(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {},
                      child: const AddTrackSheet(),
                    ),
                  ),
                ),
              ),

            // Modal Layer 2: Radial Editing Wheel
            if (editorState.isRadialMenuOpen)
              const RadialEditingMenu(),

            // Modal Layer 3: Auto Captions / Subtitles Studio
            if (editorState.isCaptionsSheetOpen)
              const Positioned.fill(
                child: AutoCaptionsSheet(),
              ),

            // Modal Layer 4: Export & Render Sheet (Sliders for Resolution & FPS rate + Download button)
            if (editorState.isExportSheetOpen)
              const Positioned.fill(
                child: ExportModalSheet(),
              ),
          ],
        ),
      ),
    );
  }
}
