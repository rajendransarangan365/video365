import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../providers/editor_provider.dart';
import '../../../services/media_service.dart';

class MediaImportSheet extends ConsumerStatefulWidget {
  const MediaImportSheet({super.key});

  @override
  ConsumerState<MediaImportSheet> createState() => _MediaImportSheetState();
}

class _MediaImportSheetState extends ConsumerState<MediaImportSheet> {
  int _selectedTab = 0; // 0 = Phone Gallery, 1 = Stock Assets

  Future<void> _pickVideo() async {
    final media = await MediaService.pickVideo();
    if (media != null) {
      ref.read(editorProvider.notifier).addMediaClip(media);
      ref.read(editorProvider.notifier).toggleMediaBrowser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported video: ${media.fileName}'),
            backgroundColor: Video365Colors.activeGreen,
          ),
        );
      }
    }
  }

  Future<void> _pickImageOrGif() async {
    final media = await MediaService.pickImageOrGif();
    if (media != null) {
      ref.read(editorProvider.notifier).addMediaClip(media);
      ref.read(editorProvider.notifier).toggleMediaBrowser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported image/GIF: ${media.fileName}'),
            backgroundColor: Video365Colors.activeGreen,
          ),
        );
      }
    }
  }

  Future<void> _pickAudio() async {
    final media = await MediaService.pickAudio();
    if (media != null) {
      ref.read(editorProvider.notifier).addMediaClip(media);
      ref.read(editorProvider.notifier).toggleMediaBrowser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported audio: ${media.fileName}'),
            backgroundColor: Video365Colors.activeGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorNotifier = ref.read(editorProvider.notifier);
    final stockMediaList = MediaService.getBundledStockMedia();

    return Container(
      height: 380,
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.video_library_rounded, color: Video365Colors.activeGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Import Media (Videos, Photos, GIFs, Audio)',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Video365Colors.secondaryText, size: 20),
                onPressed: () => editorNotifier.toggleMediaBrowser(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tabs: Phone Gallery vs Stock Samples
          Container(
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Video365Colors.panelBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? Video365Colors.activeGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Device Storage',
                        style: TextStyle(
                          color: _selectedTab == 0 ? const Color(0xFF080A0E) : Video365Colors.secondaryText,
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
                        color: _selectedTab == 1 ? Video365Colors.activeGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Stock Footage (4K/1080p)',
                        style: TextStyle(
                          color: _selectedTab == 1 ? const Color(0xFF080A0E) : Video365Colors.secondaryText,
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

          const SizedBox(height: 16),

          // Content Area
          if (_selectedTab == 0) ...[
            // Device Storage Picker Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildPickerCard(
                    title: 'Videos',
                    desc: '.mp4, .mov, 4K',
                    icon: Icons.movie_filter_rounded,
                    color: Video365Colors.activeGreen,
                    onTap: _pickVideo,
                  ),
                  _buildPickerCard(
                    title: 'Photos & GIFs',
                    desc: '.jpg, .png, .gif',
                    icon: Icons.photo_size_select_actual_rounded,
                    color: Video365Colors.cyanAccent,
                    onTap: _pickImageOrGif,
                  ),
                  _buildPickerCard(
                    title: 'Audio Music',
                    desc: '.mp3, .wav',
                    icon: Icons.music_note_rounded,
                    color: Video365Colors.purpleAccent,
                    onTap: _pickAudio,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Stock Footage List
            Expanded(
              child: ListView.separated(
                itemCount: stockMediaList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = stockMediaList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Video365Colors.panelBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Video365Colors.cardBorder),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.movie_creation_outlined, color: Video365Colors.activeGreen),
                      title: Text(
                        item.fileName,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${(item.durationMs / 1000).toInt()}s · H.264 · Royalty Free',
                        style: const TextStyle(color: Video365Colors.secondaryText, fontSize: 11),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Video365Colors.activeGreen,
                          foregroundColor: const Color(0xFF080A0E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        onPressed: () {
                          ref.read(editorProvider.notifier).addMediaClip(item);
                          ref.read(editorProvider.notifier).toggleMediaBrowser();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${item.fileName} to timeline!')),
                          );
                        },
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPickerCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Video365Colors.panelBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Video365Colors.cardBorder),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(color: Video365Colors.secondaryText, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
