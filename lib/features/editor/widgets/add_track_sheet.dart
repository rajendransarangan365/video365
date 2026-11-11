import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';

class AddTrackSheet extends ConsumerWidget {
  const AddTrackSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(editorProvider.notifier);

    final trackOptions = [
      (
        type: TrackType.video,
        title: 'Video Track',
        desc: 'Main video footage, B-roll & picture-in-picture',
        color: const Color(0xFF1565C0),
        icon: Icons.video_collection_outlined,
      ),
      (
        type: TrackType.audio,
        title: 'Audio Track',
        desc: 'Music, sound effects & ambient audio',
        color: const Color(0xFF4F46E5),
        icon: Icons.music_note_rounded,
      ),
      (
        type: TrackType.text,
        title: 'Text / Motion Graphics',
        desc: 'Lower thirds, kinetic titles & subtitles',
        color: const Color(0xFF7C3AED),
        icon: Icons.title_rounded,
      ),
      (
        type: TrackType.image,
        title: 'Image / GIF Overlay',
        desc: 'Logos, stickers, watermarks & photos',
        color: const Color(0xFF0891B2),
        icon: Icons.image_outlined,
      ),
      (
        type: TrackType.effect,
        title: 'FX Layer',
        desc: 'Visual effects, glitches, blurs & glows',
        color: const Color(0xFFF59E0B),
        icon: Icons.auto_fix_high_rounded,
      ),
      (
        type: TrackType.adjustment,
        title: 'Adjustment Layer',
        desc: 'Apply color grading across all layers beneath',
        color: const Color(0xFFDC2626),
        icon: Icons.tune_rounded,
      ),
      (
        type: TrackType.voiceover,
        title: 'Voiceover Track',
        desc: 'Dedicated narration & microphone recording',
        color: const Color(0xFF059669),
        icon: Icons.mic_rounded,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF11151D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Color(0xFF20283A), width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Video365Colors.activeGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_box_outlined, size: 18, color: Video365Colors.activeGreen),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Add Timeline Track',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Video365Colors.secondaryText),
                    onPressed: () => notifier.toggleAddTrackSheet(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Track Type Options
              ...trackOptions.map((opt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      notifier.addTrack(opt.type);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B26),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF242C3D), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: opt.color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(opt.icon, size: 18, color: opt.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.title,
                                  style: const TextStyle(
                                    color: Video365Colors.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt.desc,
                                  style: const TextStyle(
                                    color: Video365Colors.secondaryText,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.add_rounded, size: 18, color: opt.color),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

