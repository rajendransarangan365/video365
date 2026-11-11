import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';
import '../../captions/widgets/auto_captions_sheet.dart';
import '../../export/widgets/export_modal_sheet.dart';
import '../../radial_menu/widgets/radial_editing_menu.dart';
import '../widgets/bottom_tool_bar.dart';
import '../widgets/editor_top_nav_bar.dart';
import '../widgets/multi_track_timeline.dart';
import '../widgets/playback_timecode_bar.dart';
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
              children: const [
                // 1. Top Navigation Bar: [✕] [↶ ↷] Title [↑ Export]
                EditorTopNavBar(),

                // 2. Video Preview Card: Rounded 9:16 / 16:9 player with overlays
                VideoPreviewCard(),

                // 3. Playback Controls & Timecode: 0:04.2 / 0:14.0 [▶] 1080p·30fps
                PlaybackTimecodeBar(),

                // 4. Multi-Track Timeline: Video filmstrip, Text, Audio waveform, Voiceover
                Expanded(
                  child: MultiTrackTimeline(),
                ),

                // 5. Contextual Bottom Toolbar: Trim, Text, Audio, Filters, Effects, Speed
                BottomToolBar(),
              ],
            ),

            // Modal Layer 1: Radial Editing Wheel
            if (editorState.isRadialMenuOpen)
              const RadialEditingMenu(),

            // Modal Layer 2: Auto Captions / Subtitles Studio
            if (editorState.isCaptionsSheetOpen)
              const Positioned.fill(
                child: AutoCaptionsSheet(),
              ),

            // Modal Layer 3: Export & Render Sheet
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
