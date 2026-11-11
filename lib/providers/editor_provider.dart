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
  final bool isAddTrackSheetOpen;
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
    this.isAddTrackSheetOpen = false,
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

  ClipItem? get selectedClip {
    if (selectedClipId == null) return null;
    for (final track in project.tracks) {
      for (final clip in track.clips) {
        if (clip.id == selectedClipId) return clip;
      }
    }
    return null;
  }

  TrackItem? get selectedTrack {
    if (selectedTrackId == null) return null;
    try {
      return project.tracks.firstWhere((t) => t.id == selectedTrackId);
    } catch (_) {
      return null;
    }
  }

  EditorState copyWith({
    Video365Project? project,
    double? currentTimeMs,
    bool? isPlaying,
    String? selectedClipId,
    bool clearSelectedClip = false,
    String? selectedTrackId,
    bool clearSelectedTrack = false,
    double? zoomScale,
    BottomTool? activeTool,
    bool? isRadialMenuOpen,
    bool? isCaptionsSheetOpen,
    bool? isExportSheetOpen,
    bool? isMediaBrowserOpen,
    bool? isAddTrackSheetOpen,
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
      selectedClipId: clearSelectedClip ? null : (selectedClipId ?? this.selectedClipId),
      selectedTrackId: clearSelectedTrack ? null : (selectedTrackId ?? this.selectedTrackId),
      zoomScale: zoomScale ?? this.zoomScale,
      activeTool: activeTool ?? this.activeTool,
      isRadialMenuOpen: isRadialMenuOpen ?? this.isRadialMenuOpen,
      isCaptionsSheetOpen: isCaptionsSheetOpen ?? this.isCaptionsSheetOpen,
      isExportSheetOpen: isExportSheetOpen ?? this.isExportSheetOpen,
      isMediaBrowserOpen: isMediaBrowserOpen ?? this.isMediaBrowserOpen,
      isAddTrackSheetOpen: isAddTrackSheetOpen ?? this.isAddTrackSheetOpen,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      captionStyle: captionStyle ?? this.captionStyle,
      captionHighlightColor: captionHighlightColor ?? this.captionHighlightColor,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      activeFilterPreset: activeFilterPreset ?? this.activeFilterPreset,
      activeFilterIntensity: activeFilterIntensity ?? this.activeFilterIntensity,
      activeEffectType: activeEffectType ?? this.activeEffectType,
      activeEffectIntensity: activeEffectIntensity ?? this.activeEffectIntensity,
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
    return EditorState(project: _createEmptyProject('Untitled Project'));
  }

  static Video365Project _createEmptyProject(
    String name, {
    AspectRatioType aspect = AspectRatioType.ratio9_16,
    ResolutionType res = ResolutionType.res1080p,
    FrameRateType fps = FrameRateType.fps30,
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return Video365Project(
      id: 'proj_$ts',
      name: name,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      aspectRatio: aspect,
      resolution: res,
      fps: fps,
      durationMs: 0.0,
      tracks: [
        TrackItem(id: 'track_v1_$ts', type: TrackType.video, name: 'V1', clips: []),
        TrackItem(id: 'track_a1_$ts', type: TrackType.audio, name: 'A1', clips: []),
      ],
      subtitles: [],
    );
  }

  static Video365Project createDemoProject() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final videoClips = [
      ClipItem(id: 'clip_v0', trackId: 'track_v1_$ts', type: TrackType.video,
        title: 'Lisbon Intro', startMs: 0, durationMs: 4000,
        color: const Color(0xFF1565C0), isAsset: true, assetPath: 'assets/samples/sample_video365.mp4'),
      ClipItem(id: 'clip_v1', trackId: 'track_v1_$ts', type: TrackType.video,
        title: 'Sunday in Lisbon', startMs: 4000, durationMs: 4000,
        color: const Color(0xFF20C878), isAsset: true, assetPath: 'assets/samples/sample_video365.mp4'),
      ClipItem(id: 'clip_v2', trackId: 'track_v1_$ts', type: TrackType.video,
        title: 'Sunset View', startMs: 8000, durationMs: 6000,
        color: const Color(0xFF1565C0), isAsset: true, assetPath: 'assets/samples/sample_video365.mp4'),
    ];
    final textClips = [
      ClipItem(id: 'clip_t1', trackId: 'track_t1_$ts', type: TrackType.text,
        title: 'Sunday in Lisbon', startMs: 2000, durationMs: 5000,
        color: const Color(0xFF7C3AED), textContent: 'Sunday in Lisbon',
        motionGraphicsType: 'lower_third_minimal', fontSize: 32),
    ];
    final audioClips = [
      ClipItem(id: 'clip_a1', trackId: 'track_a1_$ts', type: TrackType.audio,
        title: 'Acoustic Morning Vibes', startMs: 0, durationMs: 14000,
        color: const Color(0xFF4F46E5)),
    ];
    return Video365Project(
      id: 'proj_demo',
      name: 'Sunday in Lisbon',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      modifiedAt: DateTime.now(),
      aspectRatio: AspectRatioType.ratio9_16,
      resolution: ResolutionType.res1080p,
      fps: FrameRateType.fps30,
      durationMs: 14000,
      tracks: [
        TrackItem(id: 'track_fx1_$ts', type: TrackType.effect, name: 'FX', clips: []),
        TrackItem(id: 'track_t1_$ts', type: TrackType.text, name: 'T1', clips: textClips),
        TrackItem(id: 'track_v1_$ts', type: TrackType.video, name: 'V1', clips: videoClips),
        TrackItem(id: 'track_a1_$ts', type: TrackType.audio, name: 'A1', clips: audioClips),
        TrackItem(id: 'track_vo1_$ts', type: TrackType.voiceover, name: 'VO', clips: []),
      ],
      subtitles: [],
    );
  }

  // ─── Project ──────────────────────────────────────────────────────────────

  void startNewProject(String name, {
    AspectRatioType aspect = AspectRatioType.ratio9_16,
    ResolutionType res = ResolutionType.res1080p,
    FrameRateType fps = FrameRateType.fps30,
  }) {
    pause();
    state = EditorState(project: _createEmptyProject(name, aspect: aspect, res: res, fps: fps));
  }

  void loadProject(Video365Project project) {
    pause();
    state = EditorState(project: project);
  }

  // ─── Tracks ───────────────────────────────────────────────────────────────

  void addTrack(TrackType type) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final count = state.project.tracks.where((t) => t.type == type).length + 1;
    final prefix = type.name[0].toUpperCase();
    final newTrack = TrackItem(
      id: 'track_${type.name}_$ts',
      type: type,
      name: '$prefix$count',
      clips: [],
    );

    final tracks = List<TrackItem>.from(state.project.tracks);
    // Insert at sensible position
    int idx;
    switch (type) {
      case TrackType.effect:
      case TrackType.adjustment:
        idx = 0;
        break;
      case TrackType.text:
        final firstMedia = tracks.indexWhere((t) =>
          t.type == TrackType.video || t.type == TrackType.image ||
          t.type == TrackType.audio || t.type == TrackType.voiceover);
        idx = firstMedia == -1 ? tracks.length : firstMedia;
        break;
      case TrackType.video:
      case TrackType.image:
        final firstAudio = tracks.indexWhere((t) =>
          t.type == TrackType.audio || t.type == TrackType.voiceover);
        idx = firstAudio == -1 ? tracks.length : firstAudio;
        break;
      case TrackType.audio:
        final firstVoice = tracks.indexWhere((t) => t.type == TrackType.voiceover);
        idx = firstVoice == -1 ? tracks.length : firstVoice;
        break;
      default:
        idx = tracks.length;
    }

    tracks.insert(idx, newTrack);
    state = state.copyWith(
      project: state.project.copyWith(tracks: tracks),
      isAddTrackSheetOpen: false,
    );
  }

  void removeTrack(String trackId) {
    // Need at least 1 track
    if (state.project.tracks.length <= 1) return;
    final tracks = state.project.tracks.where((t) => t.id != trackId).toList();
    state = state.copyWith(
      project: state.project.copyWith(tracks: tracks, durationMs: _calcMax(tracks)),
      clearSelectedClip: true,
      clearSelectedTrack: true,
    );
  }

  void toggleTrackMute(String trackId) {
    _mapTracks((t) => t.id == trackId ? t.copyWith(isMuted: !t.isMuted) : t);
  }

  void toggleTrackLock(String trackId) {
    _mapTracks((t) => t.id == trackId ? t.copyWith(isLocked: !t.isLocked) : t);
  }

  void toggleTrackVisibility(String trackId) {
    _mapTracks((t) => t.id == trackId ? t.copyWith(isHidden: !t.isHidden) : t);
  }

  void _mapTracks(TrackItem Function(TrackItem) fn) {
    final tracks = state.project.tracks.map(fn).toList();
    state = state.copyWith(project: state.project.copyWith(tracks: tracks));
  }

  // ─── Media ────────────────────────────────────────────────────────────────

  void addMediaClip(PickedMediaResult media, {String? targetTrackId}) {
    final tracks = List<TrackItem>.from(state.project.tracks);
    String trackId;

    if (targetTrackId != null && tracks.any((t) => t.id == targetTrackId)) {
      trackId = targetTrackId;
    } else {
      // Find first compatible unlocked track
      final compat = tracks.firstWhere(
        (t) => t.type == media.type && !t.isLocked,
        orElse: () => const TrackItem(id: '', type: TrackType.video, name: ''),
      );
      if (compat.id.isEmpty) {
        // Create a new track
        final ts2 = DateTime.now().millisecondsSinceEpoch;
        final cnt = tracks.where((t) => t.type == media.type).length + 1;
        final pfx = media.type.name[0].toUpperCase();
        final newT = TrackItem(
          id: 'track_${media.type.name}_$ts2',
          type: media.type,
          name: '$pfx$cnt',
          clips: [],
        );
        tracks.add(newT);
        trackId = newT.id;
      } else {
        trackId = compat.id;
      }
    }

    final track = tracks.firstWhere((t) => t.id == trackId);
    final insertMs = track.clips.isEmpty
        ? 0.0
        : track.clips.map((c) => c.endMs).reduce(math.max);

    final newClip = ClipItem(
      id: 'clip_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      type: media.type,
      title: media.fileName,
      startMs: insertMs,
      durationMs: media.durationMs > 0 ? media.durationMs : 5000.0,
      filePath: media.isAsset ? null : media.path,
      assetPath: media.isAsset ? media.path : null,
      isAsset: media.isAsset,
      color: _colorForType(media.type),
    );

    final updatedTracks = tracks.map((t) {
      if (t.id == trackId) return t.copyWith(clips: [...t.clips, newClip]);
      return t;
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(
        tracks: updatedTracks,
        durationMs: _calcMax(updatedTracks),
        modifiedAt: DateTime.now(),
      ),
      selectedClipId: newClip.id,
      selectedTrackId: trackId,
      isMediaBrowserOpen: false,
    );
  }

  void addEffectLayer(String effectType, {String? title, double intensity = 0.7}) {
    final fxTracks = state.project.tracks.where((t) => t.type == TrackType.effect).toList();
    String trackId;
    if (fxTracks.isEmpty) {
      addTrack(TrackType.effect);
      trackId = state.project.tracks.firstWhere((t) => t.type == TrackType.effect).id;
    } else {
      trackId = fxTracks.first.id;
    }

    final newClip = ClipItem(
      id: 'fx_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      type: TrackType.effect,
      title: title ?? 'FX: $effectType',
      startMs: state.currentTimeMs,
      durationMs: 4000,
      effectType: effectType,
      effectIntensity: intensity,
      color: const Color(0xFFF59E0B),
    );

    final updatedTracks = state.project.tracks.map((t) {
      if (t.id == trackId) return t.copyWith(clips: [...t.clips, newClip]);
      return t;
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(
        tracks: updatedTracks,
        durationMs: _calcMax(updatedTracks),
      ),
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
    final textTracks = state.project.tracks.where((t) => t.type == TrackType.text).toList();
    String trackId;
    if (textTracks.isEmpty) {
      addTrack(TrackType.text);
      trackId = state.project.tracks.firstWhere((t) => t.type == TrackType.text).id;
    } else {
      trackId = textTracks.first.id;
    }

    final newClip = ClipItem(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      type: TrackType.text,
      title: title,
      textContent: title,
      subtitleContent: subtitle,
      startMs: state.currentTimeMs,
      durationMs: 5000,
      color: color,
      textColor: Colors.white,
      fontFamily: fontFamily,
      fontSize: fontSize,
      motionGraphicsType: type,
    );

    final updatedTracks = state.project.tracks.map((t) {
      if (t.id == trackId) return t.copyWith(clips: [...t.clips, newClip]);
      return t;
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(
        tracks: updatedTracks,
        durationMs: _calcMax(updatedTracks),
      ),
      selectedClipId: newClip.id,
      selectedTrackId: trackId,
    );
  }

  void updateClip(String clipId, ClipItem Function(ClipItem) fn) {
    final updatedTracks = state.project.tracks.map((track) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx == -1) return track;
      final clips = List<ClipItem>.from(track.clips);
      clips[idx] = fn(clips[idx]);
      return track.copyWith(clips: clips);
    }).toList();
    state = state.copyWith(project: state.project.copyWith(tracks: updatedTracks));
  }

  void moveClip(String clipId, double newStartMs) {
    updateClip(clipId, (c) => c.copyWith(startMs: math.max(0.0, newStartMs)));
    _recalcDuration();
  }

  void _recalcDuration() {
    final max = _calcMax(state.project.tracks);
    state = state.copyWith(project: state.project.copyWith(durationMs: max));
  }

  // ─── Playback ─────────────────────────────────────────────────────────────

  void togglePlay() {
    if (state.project.isEmpty) return;
    state.isPlaying ? pause() : play();
  }

  void play() {
    if (state.project.isEmpty) return;
    _playbackTimer?.cancel();
    state = state.copyWith(isPlaying: true);
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      final next = state.currentTimeMs + (33.0 * state.playbackSpeed);
      if (next >= state.project.durationMs) {
        seekTo(0);
        pause();
      } else {
        state = state.copyWith(currentTimeMs: next);
      }
    });
  }

  void pause() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    if (state.isPlaying) state = state.copyWith(isPlaying: false);
  }

  void seekTo(double ms) {
    final max = state.project.isEmpty ? 0.0 : state.project.durationMs;
    state = state.copyWith(currentTimeMs: ms.clamp(0.0, max));
  }

  void stepForward() {
    seekTo(state.currentTimeMs + (1000.0 / state.project.fps.fps));
  }

  void stepBackward() {
    seekTo(state.currentTimeMs - (1000.0 / state.project.fps.fps));
  }

  void jumpToStart() => seekTo(0);
  void jumpToEnd() => seekTo(state.project.durationMs);

  // ─── Selection ────────────────────────────────────────────────────────────

  void selectClip(String? clipId, {String? trackId}) {
    state = state.copyWith(
      selectedClipId: clipId,
      clearSelectedClip: clipId == null,
      selectedTrackId: trackId,
      clearSelectedTrack: trackId == null,
    );
  }

  void deselectAll() {
    state = state.copyWith(clearSelectedClip: true, clearSelectedTrack: true);
  }

  // ─── Zoom ─────────────────────────────────────────────────────────────────

  void setZoomScale(double scale) => state = state.copyWith(zoomScale: scale.clamp(0.2, 8.0));
  void zoomIn() => setZoomScale(state.zoomScale * 1.4);
  void zoomOut() => setZoomScale(state.zoomScale / 1.4);

  // ─── Clip Ops ─────────────────────────────────────────────────────────────

  void splitSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return;
    final updatedTracks = state.project.tracks.map((track) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx == -1) return track;
      final clip = track.clips[idx];
      final split = state.currentTimeMs;
      if (split <= clip.startMs + 100 || split >= clip.endMs - 100) return track;
      final d1 = split - clip.startMs;
      final d2 = clip.durationMs - d1;
      final c1 = clip.copyWith(id: '${clip.id}_a', durationMs: d1);
      final c2 = clip.copyWith(id: '${clip.id}_b', startMs: split, durationMs: d2, sourceInMs: clip.sourceInMs + d1);
      final clips = List<ClipItem>.from(track.clips);
      clips.removeAt(idx);
      clips.insert(idx, c1);
      clips.insert(idx + 1, c2);
      return track.copyWith(clips: clips);
    }).toList();
    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks),
      selectedClipId: '${clipId}_a',
    );
  }

  void deleteSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return;
    final updatedTracks = state.project.tracks.map((t) {
      return t.copyWith(clips: t.clips.where((c) => c.id != clipId).toList());
    }).toList();
    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, durationMs: _calcMax(updatedTracks)),
      clearSelectedClip: true,
      clearSelectedTrack: true,
    );
  }

  void setClipSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
    if (state.selectedClipId != null) {
      updateClip(state.selectedClipId!, (c) => c.copyWith(speed: speed));
    }
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  void setBottomTool(BottomTool tool) {
    if (tool == BottomTool.radial) {
      state = state.copyWith(isRadialMenuOpen: !state.isRadialMenuOpen);
    } else if (tool == BottomTool.captions) {
      state = state.copyWith(isCaptionsSheetOpen: !state.isCaptionsSheetOpen);
    } else if (tool == BottomTool.media) {
      state = state.copyWith(isMediaBrowserOpen: !state.isMediaBrowserOpen);
    } else {
      state = state.copyWith(activeTool: state.activeTool == tool ? BottomTool.none : tool);
    }
  }

  void closeActiveDrawer() => state = state.copyWith(activeTool: BottomTool.none);
  void toggleRadialMenu() => state = state.copyWith(isRadialMenuOpen: !state.isRadialMenuOpen);
  void toggleCaptionsSheet() => state = state.copyWith(isCaptionsSheetOpen: !state.isCaptionsSheetOpen);
  void toggleExportSheet() => state = state.copyWith(isExportSheetOpen: !state.isExportSheetOpen);
  void toggleMediaBrowser() => state = state.copyWith(isMediaBrowserOpen: !state.isMediaBrowserOpen);
  void toggleAddTrackSheet() => state = state.copyWith(isAddTrackSheetOpen: !state.isAddTrackSheetOpen);
  void toggleFullscreen() => state = state.copyWith(isFullscreen: !state.isFullscreen);
  void toggleMute() => state = state.copyWith(isAudioMuted: !state.isAudioMuted);

  void setAspectRatio(AspectRatioType ratio) {
    state = state.copyWith(project: state.project.copyWith(aspectRatio: ratio));
  }

  void cycleAspectRatio() {
    final vals = AspectRatioType.values;
    setAspectRatio(vals[(vals.indexOf(state.project.aspectRatio) + 1) % vals.length]);
  }

  void setCaptionStyle(CaptionStyle s) => state = state.copyWith(captionStyle: s);
  void setCaptionHighlightColor(Color c) => state = state.copyWith(captionHighlightColor: c);

  // ─── Utils ────────────────────────────────────────────────────────────────

  static double _calcMax(List<TrackItem> tracks) {
    double max = 0;
    for (final t in tracks) {
      for (final c in t.clips) {
        if (c.endMs > max) max = c.endMs;
      }
    }
    return max;
  }

  static Color _colorForType(TrackType type) {
    switch (type) {
      case TrackType.video: return const Color(0xFF1565C0);
      case TrackType.audio: return const Color(0xFF4F46E5);
      case TrackType.text: return const Color(0xFF7C3AED);
      case TrackType.effect: return const Color(0xFFF59E0B);
      case TrackType.voiceover: return const Color(0xFF059669);
      case TrackType.image: return const Color(0xFF0891B2);
      case TrackType.adjustment: return const Color(0xFFDC2626);
    }
  }
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(EditorNotifier.new);
