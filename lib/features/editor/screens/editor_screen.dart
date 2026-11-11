import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';
import '../../captions/widgets/auto_captions_sheet.dart';
import '../../export/widgets/export_modal_sheet.dart';
import '../../radial_menu/widgets/radial_editing_menu.dart';
import '../widgets/bottom_tool_bar.dart';
import '../widgets/editor_top_nav_bar.dart';
import '../widgets/effects_drawer.dart';
import '../widgets/filters_drawer.dart';
import '../widgets/media_import_sheet.dart';
import '../widgets/motion_graphics_drawer.dart';
import '../widgets/multi_track_timeline.dart';
import '../widgets/playback_timecode_bar.dart';
import '../widgets/speed_drawer.dart';
import '../widgets/trim_drawer.dart';
import '../widgets/video_preview_card.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);

    return Scaffold(
      backgroundColor: Video365Colors.mainBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Base Studio Layout
            Column(
              children: [
                // 1. Top Navigation Bar: [✕] [↶ ↷] Title [↑ Export]
                const EditorTopNavBar(),

                // 2. Video Preview Card: Empty State OR Live Video with Overlays
                const VideoPreviewCard(),

                // 3. Playback Controls & Timecode
                const PlaybackTimecodeBar(),

                // 4. Multi-Track Timeline: FX, Text, Video, Audio, Voice
                const Expanded(
                  child: MultiTrackTimeline(),
                ),

                // 5. Contextual Active Tool Drawer (if open)
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

                // 6. Contextual Bottom Toolbar
                const BottomToolBar(),
              ],
            ),

            // Modal Layer 1: Media Import Sheet
            if (editorState.isMediaBrowserOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: const MediaImportSheet(),
              ),

            // Modal Layer 2: Radial Editing Wheel
            if (editorState.isRadialMenuOpen)
              const RadialEditingMenu(),

            // Modal Layer 3: Auto Captions / Subtitles Studio
            if (editorState.isCaptionsSheetOpen)
              const Positioned.fill(
                child: AutoCaptionsSheet(),
              ),

            // Modal Layer 4: Export & Render Sheet
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
