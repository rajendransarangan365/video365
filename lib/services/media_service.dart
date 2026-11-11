import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';

class PickedMediaResult {
  final String path;
  final String fileName;
  final TrackType type;
  final double durationMs;
  final bool isAsset;

  const PickedMediaResult({
    required this.path,
    required this.fileName,
    required this.type,
    this.durationMs = 5000.0,
    this.isAsset = false,
  });
}

class MediaService {
  MediaService._();

  /// Picks a video file from device storage (.mp4, .mov, .mkv, .webm, .avi)
  static Future<PickedMediaResult?> pickVideo() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'mkv', 'webm', 'avi', '3gp', 'm4v'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        if (file.path != null) {
          return PickedMediaResult(
            path: file.path!,
            fileName: file.name,
            type: TrackType.video,
            durationMs: 8000.0,
            isAsset: false,
          );
        }
      }
    } catch (e) {
      debugPrint('MediaService.pickVideo error: $e');
    }
    return null;
  }

  /// Picks an image or GIF file from device storage (.jpg, .jpeg, .png, .gif, .webp)
  static Future<PickedMediaResult?> pickImageOrGif() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        if (file.path != null) {
          return PickedMediaResult(
            path: file.path!,
            fileName: file.name,
            type: TrackType.video,
            durationMs: 4000.0,
            isAsset: false,
          );
        }
      }
    } catch (e) {
      debugPrint('MediaService.pickImageOrGif error: $e');
    }
    return null;
  }

  /// Picks an audio file from device storage (.mp3, .wav, .m4a, .aac, .ogg)
  static Future<PickedMediaResult?> pickAudio() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        if (file.path != null) {
          return PickedMediaResult(
            path: file.path!,
            fileName: file.name,
            type: TrackType.audio,
            durationMs: 15000.0,
            isAsset: false,
          );
        }
      }
    } catch (e) {
      debugPrint('MediaService.pickAudio error: $e');
    }
    return null;
  }

  /// Returns bundled sample stock assets for instant testing
  static List<PickedMediaResult> getBundledStockMedia() {
    return [
      const PickedMediaResult(
        path: 'assets/samples/sample_video365.mp4',
        fileName: '4K Landscape Cinematic Clip',
        type: TrackType.video,
        durationMs: 6000.0,
        isAsset: true,
      ),
      const PickedMediaResult(
        path: 'assets/samples/sample_video365.mp4',
        fileName: 'Vertical Street Motion (9:16)',
        type: TrackType.video,
        durationMs: 5000.0,
        isAsset: true,
      ),
      const PickedMediaResult(
        path: 'assets/samples/sample_video365.mp4',
        fileName: 'Analog Film Texture Clip',
        type: TrackType.video,
        durationMs: 4000.0,
        isAsset: true,
      ),
    ];
  }
}
