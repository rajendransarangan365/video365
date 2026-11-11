import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/video365_colors.dart';
import '../../../models/project_model.dart';
import '../../../providers/editor_provider.dart';

class ExportModalSheet extends ConsumerStatefulWidget {
  const ExportModalSheet({super.key});

  @override
  ConsumerState<ExportModalSheet> createState() => _ExportModalSheetState();
}

class _ExportModalSheetState extends ConsumerState<ExportModalSheet> {
  int _selectedResIndex = 2; // 1080p default
  int _selectedFpsIndex = 1; // 30 fps default
  bool _isExporting = false;
  double _exportProgress = 0.0;
  Timer? _progressTimer;

  static const List<String> _resolutions = ['540p', '720p', '1080p', '4K', '8K'];
  static const List<String> _fpsRates = ['24', '30', '45', '50', '60'];

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startExport() {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
    });

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_exportProgress >= 1.0) {
        timer.cancel();
        setState(() {
          _isExporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video exported successfully to Gallery! (Video365/Exports)'),
            backgroundColor: Video365Colors.activeGreen,
          ),
        );
        ref.read(editorProvider.notifier).toggleExportSheet();
      } else {
        setState(() {
          _exportProgress += 0.02;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      color: Video365Colors.mainBg,
      child: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar: ✕ | Export video | ✓
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Video365Colors.primaryText),
                    onPressed: () => editorNotifier.toggleExportSheet(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Export video',
                    style: TextStyle(
                      color: Video365Colors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.check_rounded, color: Video365Colors.activeGreen),
                    onPressed: _startExport,
                  ),
                ],
              ),
            ),

            // Preview Thumbnail
            Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF11151D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Video365Colors.cardBorder, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.movie_creation_outlined,
                          size: 44,
                          color: Video365Colors.activeGreen,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          editorState.project.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_resolutions[_selectedResIndex]} · ${_fpsRates[_selectedFpsIndex]} fps · H.264',
                          style: const TextStyle(
                            color: Video365Colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Export Progress Bar Overlay
                  if (_isExporting)
                    Container(
                      color: Colors.black.withOpacity(0.85),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rendering Frames... ${(_exportProgress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Video365Colors.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _exportProgress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFF1E2638),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Video365Colors.activeGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Settings Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Video365Colors.panelBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Video365Colors.cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resolution Slider Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Resolution',
                          style: TextStyle(
                            color: Video365Colors.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _resolutions[_selectedResIndex],
                          style: const TextStyle(
                            color: Video365Colors.activeGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Video365Colors.activeGreen,
                        inactiveTrackColor: const Color(0xFF283244),
                        thumbColor: Colors.white,
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _selectedResIndex.toDouble(),
                        min: 0,
                        max: (_resolutions.length - 1).toDouble(),
                        divisions: _resolutions.length - 1,
                        onChanged: (val) => setState(() => _selectedResIndex = val.toInt()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _resolutions.map((r) => Text(
                        r,
                        style: const TextStyle(color: Video365Colors.secondaryText, fontSize: 10),
                      )).toList(),
                    ),

                    const SizedBox(height: 24),

                    // FPS Rate Slider Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FPS rate',
                          style: TextStyle(
                            color: Video365Colors.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_fpsRates[_selectedFpsIndex]} fps',
                          style: const TextStyle(
                            color: Video365Colors.activeGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Video365Colors.activeGreen,
                        inactiveTrackColor: const Color(0xFF283244),
                        thumbColor: Colors.white,
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _selectedFpsIndex.toDouble(),
                        min: 0,
                        max: (_fpsRates.length - 1).toDouble(),
                        divisions: _fpsRates.length - 1,
                        onChanged: (val) => setState(() => _selectedFpsIndex = val.toInt()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _fpsRates.map((f) => Text(
                        f,
                        style: const TextStyle(color: Video365Colors.secondaryText, fontSize: 10),
                      )).toList(),
                    ),

                    const Spacer(),

                    // Estimated Size & Bitrate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Estimated file size',
                          style: TextStyle(color: Video365Colors.secondaryText, fontSize: 12),
                        ),
                        Text(
                          '~ 48.2 MB',
                          style: TextStyle(
                            color: Video365Colors.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Download / Export Button
                    GestureDetector(
                      onTap: _isExporting ? null : _startExport,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Video365Colors.activeGreen,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Video365Colors.activeGreen.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isExporting ? 'Exporting...' : 'Download',
                          style: const TextStyle(
                            color: Color(0xFF080A0E),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
