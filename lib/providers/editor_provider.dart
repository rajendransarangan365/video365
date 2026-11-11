import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/video365_colors.dart';
import '../models/project_model.dart';
import '../services/media_service.dart';

class EditorState {
  final Video365Project project;
  final double currentTimeMs;
  final bool isPlaying;
  final String? selectedClipId;
  final String? selectedTrackId;
  final double zoomScale;
  final BottomTool activeTool;
  final bool isRadialMenuOpen;
  final bool isCaptionsSheetOpen;
  final bool isExportSheetOpen;
  final bool isMediaBrowserOpen;
  final bool isFullscreen;
  final bool isAudioMuted;
  final CaptionStyle captionStyle;
  final Color captionHighlightColor;
  final double playbackSpeed;
  final String? activeFilterPreset;
  final double activeFilterIntensity;
  final String? activeEffectType;
  final double activeEffectIntensity;

  const EditorState({
    required this.project,
    this.currentTimeMs = 0.0,
    this.isPlaying = false,
    this.selectedClipId,
    this.selectedTrackId,
    this.zoomScale = 1.0,
    this.activeTool = BottomTool.none,
    this.isRadialMenuOpen = false,
    this.isCaptionsSheetOpen = false,
    this.isExportSheetOpen = false,
    this.isMediaBrowserOpen = false,
    this.isFullscreen = false,
    this.isAudioMuted = false,
    this.captionStyle = CaptionStyle.karaoke,
    this.captionHighlightColor = Video365Colors.activeGreen,
    this.playbackSpeed = 1.0,
    this.activeFilterPreset,
    this.activeFilterIntensity = 0.8,
    this.activeEffectType,
    this.activeEffectIntensity = 0.7,
  });

  EditorState copyWith({
    Video365Project? project,
    double? currentTimeMs,
    bool? isPlaying,
    String? selectedClipId,
    String? selectedTrackId,
    double? zoomScale,
    BottomTool? activeTool,
    bool? isRadialMenuOpen,
    bool? isCaptionsSheetOpen,
    bool? isExportSheetOpen,
    bool? isMediaBrowserOpen,
    bool? isFullscreen,
    bool? isAudioMuted,
    CaptionStyle? captionStyle,
    Color? captionHighlightColor,
    double? playbackSpeed,
    String? activeFilterPreset,
    double? activeFilterIntensity,
    String? activeEffectType,
    double? activeEffectIntensity,
  }) {
    return EditorState(
      project: project ?? this.project,
      currentTimeMs: currentTimeMs ?? this.currentTimeMs,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedClipId: selectedClipId ?? this.selectedClipId,
      selectedTrackId: selectedTrackId ?? this.selectedTrackId,
      zoomScale: zoomScale ?? this.zoomScale,
      activeTool: activeTool ?? this.activeTool,
      isRadialMenuOpen: isRadialMenuOpen ?? this.isRadialMenuOpen,
      isCaptionsSheetOpen: isCaptionsSheetOpen ?? this.isCaptionsSheetOpen,
      isExportSheetOpen: isExportSheetOpen ?? this.isExportSheetOpen,
      isMediaBrowserOpen: isMediaBrowserOpen ?? this.isMediaBrowserOpen,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      captionStyle: captionStyle ?? this.captionStyle,
      captionHighlightColor:
          captionHighlightColor ?? this.captionHighlightColor,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      activeFilterPreset: activeFilterPreset ?? this.activeFilterPreset,
      activeFilterIntensity:
          activeFilterIntensity ?? this.activeFilterIntensity,
      activeEffectType: activeEffectType ?? this.activeEffectType,
      activeEffectIntensity:
          activeEffectIntensity ?? this.activeEffectIntensity,
    );
  }
}

class EditorNotifier extends Notifier<EditorState> {
  Timer? _playbackTimer;

  @override
  EditorState build() {
    ref.onDispose(() {
      _playbackTimer?.cancel();
    });
    return _createInitialEmptyState();
  }

  static EditorState _createInitialEmptyState() {
    final emptyProject = _createEmptyProject('Untitled Project');
    return EditorState(
      project: emptyProject,
      currentTimeMs: 0.0,
      selectedClipId: null,
      selectedTrackId: null,
      activeTool: BottomTool.none,
    );
  }

  static Video365Project _createEmptyProject(
    String name, {
    AspectRatioType aspect = AspectRatioType.ratio9_16,
    ResolutionType res = ResolutionType.res1080p,
    FrameRateType fps = FrameRateType.fps30,
  }) {
    return Video365Project(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      aspectRatio: aspect,
      resolution: res,
      fps: fps,
      durationMs: 0.0,
      tracks: [
        const TrackItem(id: 'track_effect', type: TrackType.effect, name: 'Effects', clips: []),
        const TrackItem(id: 'track_text', type: TrackType.text, name: 'Text', clips: []),
        const TrackItem(id: 'track_video', type: TrackType.video, name: 'Video', clips: []),
        const TrackItem(id: 'track_audio', type: TrackType.audio, name: 'Audio', clips: []),
        const TrackItem(id: 'track_voice', type: TrackType.voiceover, name: 'Voice', clips: []),
      ],
      subtitles: [],
    );
  }

  static Video365Project createDemoProject() {
    final videoClips = [
      ClipItem(
        id: 'clip_video_0',
        trackId: 'track_video',
        type: TrackType.video,
        title: 'Lisbon Intro',
        startMs: 0.0,
        durationMs: 4000.0,
        color: const Color(0xFF1E2638),
        assetPath: 'assets/samples/sample_video365.mp4',
        isAsset: true,
      ),
      ClipItem(
        id: 'clip_video_1',
        trackId: 'track_video',
        type: TrackType.video,
        title: 'Sunday in Lisbon',
        startMs: 4000.0,
        durationMs: 4000.0,
        color: const Color(0xFF20C878),
        assetPath: 'assets/samples/sample_video365.mp4',
        isAsset: true,
      ),
      ClipItem(
        id: 'clip_video_2',
        trackId: 'track_video',
        type: TrackType.video,
        title: 'Sunset View',
        startMs: 8000.0,
        durationMs: 6000.0,
        color: const Color(0xFF1E2638),
        assetPath: 'assets/samples/sample_video365.mp4',
        isAsset: true,
      ),
    ];

    final textClips = [
      const ClipItem(
        id: 'clip_text_1',
        trackId: 'track_text',
        type: TrackType.text,
        title: 'Sunday in Lisbon',
        startMs: 2000.0,
        durationMs: 5000.0,
        color: Color(0xFF2563EB),
        textContent: 'Sunday in Lisbon',
        subtitleContent: 'CINEMATIC VLOG',
        motionGraphicsType: 'lower_third_minimal',
        fontSize: 32.0,
      ),
    ];

    final audioClips = [
      const ClipItem(
        id: 'clip_audio_1',
        trackId: 'track_audio',
        type: TrackType.audio,
        title: 'Acoustic Morning Vibes',
        startMs: 0.0,
        durationMs: 14000.0,
        color: Color(0xFF4F46E5),
      ),
    ];

    final tracks = [
      const TrackItem(id: 'track_effect', type: TrackType.effect, name: 'Effects', clips: []),
      TrackItem(id: 'track_text', type: TrackType.text, name: 'Text', clips: textClips),
      TrackItem(id: 'track_video', type: TrackType.video, name: 'Video', clips: videoClips),
      TrackItem(id: 'track_audio', type: TrackType.audio, name: 'Music', clips: audioClips),
      const TrackItem(id: 'track_voice', type: TrackType.voiceover, name: 'Voice', clips: []),
    ];

    final subtitles = [
      const SubtitleItem(
        id: 'sub_1',
        startMs: 400.0,
        endMs: 3500.0,
        text: "okay so it's Sunday morning in Lisbon",
        words: [
          SubtitleWord(startMs: 400, endMs: 800, word: "okay"),
          SubtitleWord(startMs: 850, endMs: 1100, word: "so"),
          SubtitleWord(startMs: 1150, endMs: 1400, word: "it's"),
          SubtitleWord(startMs: 1450, endMs: 1900, word: "Sunday"),
          SubtitleWord(startMs: 1950, endMs: 2400, word: "morning"),
          SubtitleWord(startMs: 2450, endMs: 2700, word: "in"),
          SubtitleWord(startMs: 2750, endMs: 3500, word: "Lisbon"),
        ],
      ),
      const SubtitleItem(
        id: 'sub_2',
        startMs: 3800.0,
        endMs: 5800.0,
        text: "we found this tiny bakery",
        words: [
          SubtitleWord(startMs: 3800, endMs: 4000, word: "we"),
          SubtitleWord(startMs: 4050, endMs: 4350, word: "found"),
          SubtitleWord(startMs: 4400, endMs: 4600, word: "this"),
          SubtitleWord(startMs: 4650, endMs: 5100, word: "tiny"),
          SubtitleWord(startMs: 5150, endMs: 5800, word: "bakery"),
        ],
      ),
      const SubtitleItem(
        id: 'sub_3',
        startMs: 6100.0,
        endMs: 8500.0,
        text: "and honestly the pastel de nata here",
        words: [
          SubtitleWord(startMs: 6100, endMs: 6300, word: "and"),
          SubtitleWord(startMs: 6350, endMs: 6800, word: "honestly"),
          SubtitleWord(startMs: 6850, endMs: 7000, word: "the"),
          SubtitleWord(startMs: 7050, endMs: 7500, word: "pastel"),
          SubtitleWord(startMs: 7550, endMs: 7750, word: "de"),
          SubtitleWord(startMs: 7800, endMs: 8100, word: "nata"),
          SubtitleWord(startMs: 8150, endMs: 8500, word: "here"),
        ],
      ),
      const SubtitleItem(
        id: 'sub_4',
        startMs: 9000.0,
        endMs: 12500.0,
        text: "is the best thing I've eaten all year",
        words: [
          SubtitleWord(startMs: 9000, endMs: 9200, word: "is"),
          SubtitleWord(startMs: 9250, endMs: 9400, word: "the"),
          SubtitleWord(startMs: 9450, endMs: 9750, word: "best"),
          SubtitleWord(startMs: 9800, endMs: 10100, word: "thing"),
          SubtitleWord(startMs: 10150, endMs: 10400, word: "I've"),
          SubtitleWord(startMs: 10450, endMs: 10850, word: "eaten"),
          SubtitleWord(startMs: 10900, endMs: 11100, word: "all"),
          SubtitleWord(startMs: 11150, endMs: 12500, word: "year"),
        ],
      ),
    ];

    return Video365Project(
      id: 'proj_demo_1',
      name: 'Sunday in Lisbon',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      modifiedAt: DateTime.now(),
      aspectRatio: AspectRatioType.ratio9_16,
      resolution: ResolutionType.res1080p,
      fps: FrameRateType.fps30,
      durationMs: 14000.0,
      tracks: tracks,
      subtitles: subtitles,
    );
  }

  void startNewProject(
    String name, {
    AspectRatioType aspect = AspectRatioType.ratio9_16,
    ResolutionType res = ResolutionType.res1080p,
    FrameRateType fps = FrameRateType.fps30,
  }) {
    pause();
    final p = _createEmptyProject(name, aspect: aspect, res: res, fps: fps);
    state = state.copyWith(
      project: p,
      currentTimeMs: 0.0,
      selectedClipId: null,
      selectedTrackId: null,
      activeTool: BottomTool.none,
      isRadialMenuOpen: false,
      isCaptionsSheetOpen: false,
      isExportSheetOpen: false,
    );
  }

  void loadProject(Video365Project project) {
    pause();
    state = state.copyWith(
      project: project,
      currentTimeMs: project.isEmpty ? 0.0 : math.min(project.durationMs, 4200.0),
      selectedClipId: project.tracks.isNotEmpty && project.tracks.first.clips.isNotEmpty
          ? project.tracks.first.clips.first.id
          : null,
      activeTool: BottomTool.none,
    );
  }

  void addMediaClip(PickedMediaResult media) {
    final trackId = media.type == TrackType.audio ? 'track_audio' : 'track_video';

    // Find insertion start time: at playhead or end of existing track
    final trackIndex = state.project.tracks.indexWhere((t) => t.id == trackId);
    double insertStartMs = state.currentTimeMs;
    if (trackIndex != -1 && state.project.tracks[trackIndex].clips.isNotEmpty) {
      final lastClip = state.project.tracks[trackIndex].clips.last;
      insertStartMs = lastClip.endMs;
    }

    final newClip = ClipItem(
      id: 'clip_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      type: media.type,
      title: media.fileName,
      startMs: insertStartMs,
      durationMs: media.durationMs,
      filePath: media.isAsset ? null : media.path,
      assetPath: media.isAsset ? media.path : null,
      isAsset: media.isAsset,
      color: media.type == TrackType.audio ? const Color(0xFF4F46E5) : const Color(0xFF20C878),
    );

    final updatedTracks = state.project.tracks.map((track) {
      if (track.id == trackId) {
        return track.copyWith(clips: [...track.clips, newClip]);
      }
      return track;
    }).toList();

    // Recalculate duration
    double maxEnd = 0.0;
    for (final t in updatedTracks) {
      for (final c in t.clips) {
        if (c.endMs > maxEnd) maxEnd = c.endMs;
      }
    }

    state = state.copyWith(
      project: state.project.copyWith(
        tracks: updatedTracks,
        durationMs: maxEnd,
      ),
      selectedClipId: newClip.id,
      selectedTrackId: trackId,
      currentTimeMs: newClip.startMs,
    );
  }

  void addEffectLayer(String effectType, {String? title, double intensity = 0.7}) {
    final trackId = 'track_effect';
    final insertStartMs = state.currentTimeMs;
    const duration = 4000.0;

    final newClip = ClipItem(
      id: 'effect_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      type: TrackType.effect,
      title: title ?? 'FX: $effectType',
      startMs: insertStartMs,
      durationMs: duration,
      effectType: effectType,
      effectIntensity: intensity,
      color: const Color(0xFFD97706),
    );

    final updatedTracks = state.project.tracks.map((track) {
      if (track.id == trackId) {
        return track.copyWith(clips: [...track.clips, newClip]);
      }
      return track;
    }).toList();

    double maxEnd = state.project.durationMs;
    if (newClip.endMs > maxEnd) maxEnd = newClip.endMs;

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, durationMs: maxEnd),
      selectedClipId: newClip.id,
      selectedTrackId: trackId,
      activeEffectType: effectType,
      activeEffectIntensity: intensity,
    );
  }

  void applyFilterPreset(String preset, double intensity) {
    state = state.copyWith(
      activeFilterPreset: preset == 'none' ? null : preset,
      activeFilterIntensity: intensity,
    );
  }

  void addMotionGraphicsTitle({
    required String title,
    String? subtitle,
    String type = 'lower_third_minimal',
    Color color = Video365Colors.activeGreen,
    String fontFamily = 'Roboto',
    double fontSize = 28.0,
  }) {
    final trackId = 'track_text';
    final insertStartMs = state.currentTimeMs;
    const duration = 5000.0;

    final newClip = ClipItem(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      type: TrackType.text,
      title: title,
      textContent: title,
      subtitleContent: subtitle,
      startMs: insertStartMs,
      durationMs: duration,
      color: color,
      textColor: Colors.white,
      fontFamily: fontFamily,
      fontSize: fontSize,
      motionGraphicsType: type,
    );

    final updatedTracks = state.project.tracks.map((track) {
      if (track.id == trackId) {
        return track.copyWith(clips: [...track.clips, newClip]);
      }
      return track;
    }).toList();

    double maxEnd = state.project.durationMs;
    if (newClip.endMs > maxEnd) maxEnd = newClip.endMs;

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, durationMs: maxEnd),
      selectedClipId: newClip.id,
      selectedTrackId: trackId,
    );
  }

  void togglePlay() {
    if (state.project.isEmpty) return;
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    if (state.project.isEmpty) return;
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: true);

    const tickMs = 33; // ~30 fps update
    _playbackTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      final nextTime = state.currentTimeMs + (tickMs * state.playbackSpeed);
      if (nextTime >= state.project.durationMs) {
        seekTo(0.0);
        pause();
      } else {
        state = state.copyWith(currentTimeMs: nextTime);
      }
    });
  }

  void pause() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    state = state.copyWith(isPlaying: false);
  }

  void seekTo(double timeMs) {
    final maxDuration = state.project.isEmpty ? 0.0 : state.project.durationMs;
    final clamped = timeMs.clamp(0.0, maxDuration);
    state = state.copyWith(currentTimeMs: clamped);
  }

  void selectClip(String? clipId, {String? trackId}) {
    state = state.copyWith(
      selectedClipId: clipId,
      selectedTrackId: trackId,
    );
  }

  void setZoomScale(double scale) {
    state = state.copyWith(zoomScale: scale.clamp(0.5, 4.0));
  }

  void setBottomTool(BottomTool tool) {
    if (tool == BottomTool.radial) {
      toggleRadialMenu();
    } else if (tool == BottomTool.captions) {
      toggleCaptionsSheet();
    } else if (tool == BottomTool.media) {
      toggleMediaBrowser();
    } else {
      // Toggle or switch
      if (state.activeTool == tool) {
        state = state.copyWith(activeTool: BottomTool.none);
      } else {
        state = state.copyWith(activeTool: tool);
      }
    }
  }

  void closeActiveDrawer() {
    state = state.copyWith(activeTool: BottomTool.none);
  }

  void toggleRadialMenu() {
    state = state.copyWith(isRadialMenuOpen: !state.isRadialMenuOpen);
  }

  void toggleCaptionsSheet() {
    state = state.copyWith(isCaptionsSheetOpen: !state.isCaptionsSheetOpen);
  }

  void toggleExportSheet() {
    state = state.copyWith(isExportSheetOpen: !state.isExportSheetOpen);
  }

  void toggleMediaBrowser() {
    state = state.copyWith(isMediaBrowserOpen: !state.isMediaBrowserOpen);
  }

  void toggleFullscreen() {
    state = state.copyWith(isFullscreen: !state.isFullscreen);
  }

  void toggleMute() {
    state = state.copyWith(isAudioMuted: !state.isAudioMuted);
  }

  void setAspectRatio(AspectRatioType ratio) {
    state = state.copyWith(
      project: state.project.copyWith(aspectRatio: ratio),
    );
  }

  void cycleAspectRatio() {
    final values = AspectRatioType.values;
    final currentIndex = values.indexOf(state.project.aspectRatio);
    final nextIndex = (currentIndex + 1) % values.length;
    setAspectRatio(values[nextIndex]);
  }

  void setCaptionStyle(CaptionStyle style) {
    state = state.copyWith(captionStyle: style);
  }

  void setCaptionHighlightColor(Color color) {
    state = state.copyWith(captionHighlightColor: color);
  }

  void setClipSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
    final clipId = state.selectedClipId;
    if (clipId == null) return;

    final updatedTracks = state.project.tracks.map((track) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex == -1) return track;

      final clip = track.clips[clipIndex];
      final newClips = List<ClipItem>.from(track.clips);
      newClips[clipIndex] = clip.copyWith(speed: speed);
      return track.copyWith(clips: newClips);
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks),
    );
  }

  void splitSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return;

    final updatedTracks = state.project.tracks.map((track) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex == -1) return track;

      final clip = track.clips[clipIndex];
      final splitPoint = state.currentTimeMs;

      // Ensure split is within the clip boundaries
      if (splitPoint <= clip.startMs + 200 || splitPoint >= clip.endMs - 200) {
        return track;
      }

      final firstDuration = splitPoint - clip.startMs;
      final secondDuration = clip.durationMs - firstDuration;

      final firstClip = clip.copyWith(
        id: '${clip.id}_part1',
        durationMs: firstDuration,
      );

      final secondClip = clip.copyWith(
        id: '${clip.id}_part2',
        startMs: splitPoint,
        durationMs: secondDuration,
        sourceInMs: clip.sourceInMs + firstDuration,
      );

      final newClips = List<ClipItem>.from(track.clips);
      newClips.removeAt(clipIndex);
      newClips.insert(clipIndex, firstClip);
      newClips.insert(clipIndex + 1, secondClip);

      return track.copyWith(clips: newClips);
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks),
      selectedClipId: '${clipId}_part1',
    );
  }

  void deleteSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return;

    final updatedTracks = state.project.tracks.map((track) {
      final newClips = track.clips.where((c) => c.id != clipId).toList();
      return track.copyWith(clips: newClips);
    }).toList();

    double maxEnd = 0.0;
    for (final t in updatedTracks) {
      for (final c in t.clips) {
        if (c.endMs > maxEnd) maxEnd = c.endMs;
      }
    }

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, durationMs: maxEnd),
      selectedClipId: null,
      selectedTrackId: null,
    );
  }
}

final editorProvider =
    NotifierProvider<EditorNotifier, EditorState>(EditorNotifier.new);
