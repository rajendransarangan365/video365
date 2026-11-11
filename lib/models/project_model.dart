import 'package:flutter/material.dart';

enum AspectRatioType {
  ratio9_16('9:16', 9 / 16, 'TikTok / Reels / Shorts', 1080, 1920),
  ratio16_9('16:9', 16 / 9, 'YouTube / Landscape', 1920, 1080),
  ratio1_1('1:1', 1.0, 'Instagram Square', 1080, 1080),
  ratio4_5('4:5', 4 / 5, 'Instagram Portrait', 1080, 1350),
  ratio21_9('21:9', 21 / 9, 'Cinematic Ultrawide', 2560, 1080);

  final String label;
  final double ratio;
  final String description;
  final int defaultWidth;
  final int defaultHeight;

  const AspectRatioType(
    this.label,
    this.ratio,
    this.description,
    this.defaultWidth,
    this.defaultHeight,
  );
}

enum ResolutionType {
  res720p('720p (HD)', 1280, 720),
  res1080p('1080p (FHD)', 1920, 1080),
  res4K('4K (UHD)', 3840, 2160);

  final String label;
  final int width;
  final int height;

  const ResolutionType(this.label, this.width, this.height);
}

enum FrameRateType {
  fps24('24 fps (Cinema)', 24),
  fps30('30 fps (Standard)', 30),
  fps60('60 fps (Smooth)', 60);

  final String label;
  final int fps;

  const FrameRateType(this.label, this.fps);
}

enum TrackType {
  video('Video', Icons.video_collection_outlined),
  image('Image/GIF', Icons.image_outlined),
  text('Text', Icons.title_rounded),
  audio('Audio', Icons.music_note_rounded),
  voiceover('Voiceover', Icons.mic_rounded),
  effect('FX Layer', Icons.auto_fix_high_rounded),
  adjustment('Adjustment', Icons.tune_rounded);

  final String label;
  final IconData icon;

  const TrackType(this.label, this.icon);
}

enum BottomTool {
  none('None'),
  trim('Trim'),
  text('Text'),
  audio('Audio'),
  filters('Filters'),
  effects('Effects'),
  speed('Speed'),
  captions('Captions'),
  media('Add Media'),
  radial('Wheel');

  final String label;
  const BottomTool(this.label);
}

enum CaptionStyle {
  karaoke('Karaoke'),
  classic('Classic'),
  bold('BOLD'),
  mono('Mono');

  final String label;
  const CaptionStyle(this.label);
}

enum KeyframeProperty {
  scale('Scale'),
  opacity('Opacity'),
  positionX('Position X'),
  positionY('Position Y'),
  rotation('Rotation');

  final String label;
  const KeyframeProperty(this.label);
}

enum TransitionType {
  none('None', Icons.block_rounded),
  crossDissolve('Dissolve', Icons.blur_on_rounded),
  fadeToBlack('Fade Black', Icons.brightness_medium_rounded),
  wipeLeft('Wipe Left', Icons.swipe_left_rounded),
  wipeRight('Wipe Right', Icons.swipe_right_rounded),
  zoomIn('Zoom In', Icons.zoom_in_rounded),
  glitch('Glitch', Icons.flash_on_rounded);

  final String label;
  final IconData icon;
  const TransitionType(this.label, this.icon);
}

class ClipTransition {
  final String id;
  final String leftClipId;
  final String rightClipId;
  final TransitionType type;
  final double durationMs;

  const ClipTransition({
    required this.id,
    required this.leftClipId,
    required this.rightClipId,
    required this.type,
    this.durationMs = 500.0,
  });

  ClipTransition copyWith({
    String? id,
    String? leftClipId,
    String? rightClipId,
    TransitionType? type,
    double? durationMs,
  }) {
    return ClipTransition(
      id: id ?? this.id,
      leftClipId: leftClipId ?? this.leftClipId,
      rightClipId: rightClipId ?? this.rightClipId,
      type: type ?? this.type,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

class Keyframe {
  final double timeMs;
  final double value;
  final KeyframeProperty property;
  final String easing;

  const Keyframe({
    required this.timeMs,
    required this.value,
    this.property = KeyframeProperty.scale,
    this.easing = 'easeInOut',
  });

  Keyframe copyWith({
    double? timeMs,
    double? value,
    KeyframeProperty? property,
    String? easing,
  }) {
    return Keyframe(
      timeMs: timeMs ?? this.timeMs,
      value: value ?? this.value,
      property: property ?? this.property,
      easing: easing ?? this.easing,
    );
  }
}

class SubtitleWord {
  final double startMs;
  final double endMs;
  final String word;

  const SubtitleWord({
    required this.startMs,
    required this.endMs,
    required this.word,
  });
}

class SubtitleItem {
  final String id;
  final double startMs;
  final double endMs;
  final String text;
  final double confidence;
  final List<SubtitleWord> words;

  const SubtitleItem({
    required this.id,
    required this.startMs,
    required this.endMs,
    required this.text,
    this.confidence = 0.98,
    this.words = const [],
  });
}

class ClipItem {
  final String id;
  final String trackId;
  final TrackType type;
  final String title;
  final double startMs;
  final double durationMs;
  final double sourceInMs;
  final double sourceOutMs;
  final String? assetPath;
  final String? filePath;
  final bool isAsset;
  final Color color;
  final double opacity;
  final double scale;
  final double rotation;
  final Offset position;
  final double speed;
  final double volume;
  final String? textContent;
  final String? subtitleContent;
  final String? fontFamily;
  final double fontSize;
  final Color textColor;
  final String? filterPreset;
  final double filterIntensity;
  final String? effectType;
  final double effectIntensity;
  final String? motionGraphicsType;
  final List<Keyframe> keyframes;

  const ClipItem({
    required this.id,
    required this.trackId,
    required this.type,
    required this.title,
    required this.startMs,
    required this.durationMs,
    this.sourceInMs = 0,
    this.sourceOutMs = 0,
    this.assetPath,
    this.filePath,
    this.isAsset = false,
    this.color = const Color(0xFF20C878),
    this.opacity = 1.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.position = Offset.zero,
    this.speed = 1.0,
    this.volume = 1.0,
    this.textContent,
    this.subtitleContent,
    this.fontFamily,
    this.fontSize = 24.0,
    this.textColor = Colors.white,
    this.filterPreset,
    this.filterIntensity = 0.8,
    this.effectType,
    this.effectIntensity = 0.7,
    this.motionGraphicsType,
    this.keyframes = const [],
  });

  double get endMs => startMs + durationMs;

  ClipItem copyWith({
    String? id,
    String? trackId,
    TrackType? type,
    String? title,
    double? startMs,
    double? durationMs,
    double? sourceInMs,
    double? sourceOutMs,
    String? assetPath,
    String? filePath,
    bool? isAsset,
    Color? color,
    double? opacity,
    double? scale,
    double? rotation,
    Offset? position,
    double? speed,
    double? volume,
    String? textContent,
    String? subtitleContent,
    String? fontFamily,
    double? fontSize,
    Color? textColor,
    String? filterPreset,
    double? filterIntensity,
    String? effectType,
    double? effectIntensity,
    String? motionGraphicsType,
    List<Keyframe>? keyframes,
  }) {
    return ClipItem(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      type: type ?? this.type,
      title: title ?? this.title,
      startMs: startMs ?? this.startMs,
      durationMs: durationMs ?? this.durationMs,
      sourceInMs: sourceInMs ?? this.sourceInMs,
      sourceOutMs: sourceOutMs ?? this.sourceOutMs,
      assetPath: assetPath ?? this.assetPath,
      filePath: filePath ?? this.filePath,
      isAsset: isAsset ?? this.isAsset,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      position: position ?? this.position,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      textContent: textContent ?? this.textContent,
      subtitleContent: subtitleContent ?? this.subtitleContent,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      filterPreset: filterPreset ?? this.filterPreset,
      filterIntensity: filterIntensity ?? this.filterIntensity,
      effectType: effectType ?? this.effectType,
      effectIntensity: effectIntensity ?? this.effectIntensity,
      motionGraphicsType: motionGraphicsType ?? this.motionGraphicsType,
      keyframes: keyframes ?? this.keyframes,
    );
  }

  /// Evaluates an animated property at a relative timestamp within the clip (0 <= relativeMs <= durationMs)
  /// using Bezier / easing curve interpolation between keyframes inspired by VectorCraft / FilmCraft.
  double evaluateProperty(KeyframeProperty property, double relativeMs, double fallback) {
    final list = keyframes.where((k) => k.property == property).toList();
    if (list.isEmpty) return fallback;
    list.sort((a, b) => a.timeMs.compareTo(b.timeMs));

    if (relativeMs <= list.first.timeMs) {
      return list.first.value;
    }
    if (relativeMs >= list.last.timeMs) {
      return list.last.value;
    }

    for (int i = 0; i < list.length - 1; i++) {
      final kA = list[i];
      final kB = list[i + 1];
      if (relativeMs >= kA.timeMs && relativeMs <= kB.timeMs) {
        final span = kB.timeMs - kA.timeMs;
        if (span <= 0) return kB.value;
        final rawT = ((relativeMs - kA.timeMs) / span).clamp(0.0, 1.0);
        double curvedT = rawT;
        switch (kB.easing) {
          case 'easeIn':
            curvedT = Curves.easeIn.transform(rawT);
            break;
          case 'easeOut':
            curvedT = Curves.easeOut.transform(rawT);
            break;
          case 'easeInOut':
            curvedT = Curves.easeInOut.transform(rawT);
            break;
          case 'linear':
          default:
            curvedT = rawT;
            break;
        }
        return kA.value + (kB.value - kA.value) * curvedT;
      }
    }
    return fallback;
  }
}

class TrackItem {
  final String id;
  final TrackType type;
  final String name;
  final bool isMuted;
  final bool isLocked;
  final bool isHidden;
  final List<ClipItem> clips;

  const TrackItem({
    required this.id,
    required this.type,
    required this.name,
    this.isMuted = false,
    this.isLocked = false,
    this.isHidden = false,
    this.clips = const [],
  });

  TrackItem copyWith({
    String? id,
    TrackType? type,
    String? name,
    bool? isMuted,
    bool? isLocked,
    bool? isHidden,
    List<ClipItem>? clips,
  }) {
    return TrackItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isMuted: isMuted ?? this.isMuted,
      isLocked: isLocked ?? this.isLocked,
      isHidden: isHidden ?? this.isHidden,
      clips: clips ?? this.clips,
    );
  }
}

class Video365Project {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final AspectRatioType aspectRatio;
  final ResolutionType resolution;
  final FrameRateType fps;
  final double durationMs;
  final List<TrackItem> tracks;
  final List<SubtitleItem> subtitles;
  final List<ClipTransition> transitions;
  final String? thumbnailAsset;

  const Video365Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.modifiedAt,
    this.aspectRatio = AspectRatioType.ratio9_16,
    this.resolution = ResolutionType.res1080p,
    this.fps = FrameRateType.fps30,
    this.durationMs = 0.0,
    this.tracks = const [],
    this.subtitles = const [],
    this.transitions = const [],
    this.thumbnailAsset,
  });

  bool get isEmpty {
    return tracks.every((t) => t.clips.isEmpty);
  }

  Video365Project copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? modifiedAt,
    AspectRatioType? aspectRatio,
    ResolutionType? resolution,
    FrameRateType? fps,
    double? durationMs,
    List<TrackItem>? tracks,
    List<SubtitleItem>? subtitles,
    List<ClipTransition>? transitions,
    String? thumbnailAsset,
  }) {
    return Video365Project(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      resolution: resolution ?? this.resolution,
      fps: fps ?? this.fps,
      durationMs: durationMs ?? this.durationMs,
      tracks: tracks ?? this.tracks,
      subtitles: subtitles ?? this.subtitles,
      transitions: transitions ?? this.transitions,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
    );
  }
}
