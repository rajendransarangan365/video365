package com.tharunbirla.librecuts.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import android.net.Uri
import com.tharunbirla.librecuts.Video365Engine
import com.tharunbirla.librecuts.engine.JsxPresetEngine
import com.tharunbirla.librecuts.engine.SampleVideo365Project
import com.tharunbirla.librecuts.models.v2.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.util.ArrayDeque
import java.util.UUID

/**
 * Primary ViewModel driving Video365 modern Tailwind workspace.
 * Features:
 * - Real-time 60fps timeline playhead ticker tracking ExoPlayer playback
 * - Play/Pause and Mute state management
 * - Undo / Redo history stack
 * - Multi-track layer movement/trimming, split, duplicate, and delete
 * - Add Extra Layer (Text, Audio, Sticker/Shape, Video, Adjustment)
 * - Custom font/typography and Lumetri effects
 */
class Video365ViewModel : ViewModel() {
    private val _project = MutableStateFlow<Video365Project?>(null)
    val project: StateFlow<Video365Project?> = _project.asStateFlow()

    private val _currentTimeMs = MutableStateFlow(0L)
    val currentTimeMs: StateFlow<Long> = _currentTimeMs.asStateFlow()

    private val _isPlaying = MutableStateFlow(true)
    val isPlaying: StateFlow<Boolean> = _isPlaying.asStateFlow()

    private val _aspectRatio = MutableStateFlow("9:16")
    val aspectRatio: StateFlow<String> = _aspectRatio.asStateFlow()

    private val _isMuted = MutableStateFlow(false)
    val isMuted: StateFlow<Boolean> = _isMuted.asStateFlow()

    private val _snappingEnabled = MutableStateFlow(true)
    val snappingEnabled: StateFlow<Boolean> = _snappingEnabled.asStateFlow()

    private val _playbackSpeed = MutableStateFlow(1.0f)
    val playbackSpeed: StateFlow<Float> = _playbackSpeed.asStateFlow()

    private val _selectedLayerId = MutableStateFlow<String?>("lyr_mo_title")
    val selectedLayerId: StateFlow<String?> = _selectedLayerId.asStateFlow()

    private val _hiddenLayerIds = MutableStateFlow<Set<String>>(emptySet())
    val hiddenLayerIds: StateFlow<Set<String>> = _hiddenLayerIds.asStateFlow()

    private val _mutedLayerIds = MutableStateFlow<Set<String>>(emptySet())
    val mutedLayerIds: StateFlow<Set<String>> = _mutedLayerIds.asStateFlow()

    private val _isDollyEnabled = MutableStateFlow(false)
    val isDollyEnabled: StateFlow<Boolean> = _isDollyEnabled.asStateFlow()

    private val _activeTransition = MutableStateFlow<String?>("whip_pan")
    val activeTransition: StateFlow<String?> = _activeTransition.asStateFlow()

    private val _transitionProgress = MutableStateFlow(0.0f)
    val transitionProgress: StateFlow<Float> = _transitionProgress.asStateFlow()

    private val _exposure = MutableStateFlow(0.0f)
    val exposure: StateFlow<Float> = _exposure.asStateFlow()

    private val _contrast = MutableStateFlow(1.0f)
    val contrast: StateFlow<Float> = _contrast.asStateFlow()

    private val _saturation = MutableStateFlow(1.0f)
    val saturation: StateFlow<Float> = _saturation.asStateFlow()

    private val _vignette = MutableStateFlow(0.0f)
    val vignette: StateFlow<Float> = _vignette.asStateFlow()

    private val _chromaKeyEnabled = MutableStateFlow(false)
    val chromaKeyEnabled: StateFlow<Boolean> = _chromaKeyEnabled.asStateFlow()

    private val _chromaThreshold = MutableStateFlow(0.4f)
    val chromaThreshold: StateFlow<Float> = _chromaThreshold.asStateFlow()

    // Typography & Custom Fonts
    private val _activeFontPath = MutableStateFlow<String?>(null)
    val activeFontPath: StateFlow<String?> = _activeFontPath.asStateFlow()

    private val _activeFontName = MutableStateFlow("Montserrat (Modern)")
    val activeFontName: StateFlow<String> = _activeFontName.asStateFlow()

    private val _activeTextContent = MutableStateFlow("VIDEO365 STUDIO")
    val activeTextContent: StateFlow<String> = _activeTextContent.asStateFlow()

    private val _activeTextColor = MutableStateFlow("#FFFFFF")
    val activeTextColor: StateFlow<String> = _activeTextColor.asStateFlow()

    private val _activeFontSize = MutableStateFlow(22f)
    val activeFontSize: StateFlow<Float> = _activeFontSize.asStateFlow()

    // Undo / Redo Stacks
    private val undoStack = ArrayDeque<Video365Project>()
    private val redoStack = ArrayDeque<Video365Project>()

    var player: com.google.android.exoplayer2.ExoPlayer? = null
    private var playbackTickerJob: Job? = null

    private fun saveSnapshot() {
        _project.value?.let { proj ->
            undoStack.addLast(proj)
            if (undoStack.size > 25) {
                undoStack.removeFirst()
            }
            redoStack.clear()
        }
    }

    fun undo() {
        if (undoStack.isNotEmpty()) {
            _project.value?.let { redoStack.addLast(it) }
            val prev = undoStack.removeLast()
            _project.value = prev
            Video365Engine.updateProjectState(prev)
        }
    }

    fun redo() {
        if (redoStack.isNotEmpty()) {
            _project.value?.let { undoStack.addLast(it) }
            val next = redoStack.removeLast()
            _project.value = next
            Video365Engine.updateProjectState(next)
        }
    }

    /**
     * Attaches ExoPlayer and launches real-time 60fps playhead ticker coroutine.
     */
    fun attachPlayer(p: com.google.android.exoplayer2.ExoPlayer) {
        player = p
        _isPlaying.value = p.isPlaying

        p.addListener(object : com.google.android.exoplayer2.Player.Listener {
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                _isPlaying.value = isPlaying
            }
            override fun onPlaybackStateChanged(state: Int) {
                if (state == com.google.android.exoplayer2.Player.STATE_ENDED) {
                    _isPlaying.value = false
                }
            }
        })

        playbackTickerJob?.cancel()
        playbackTickerJob = viewModelScope.launch(Dispatchers.Main) {
            while (isActive) {
                val curPlayer = player
                if (curPlayer != null && curPlayer.isPlaying) {
                    _currentTimeMs.value = curPlayer.currentPosition
                }
                delay(16) // 60fps smooth timeline tracking!
            }
        }
    }

    fun togglePlayPause() {
        val p = player ?: return
        if (p.isPlaying) {
            p.pause()
            _isPlaying.value = false
        } else {
            p.play()
            _isPlaying.value = true
        }
    }

    fun toggleMute() {
        val p = player ?: return
        val next = !_isMuted.value
        _isMuted.value = next
        p.volume = if (next) 0.0f else 1.0f
    }

    fun stepFrame(deltaFrames: Int) {
        val p = player ?: return
        if (p.isPlaying) {
            p.pause()
            _isPlaying.value = false
        }
        val duration = _project.value?.compositions?.firstOrNull()?.durationMs ?: 15000L
        val frameMs = 33L // ~30fps frame time
        val target = (_currentTimeMs.value + deltaFrames * frameMs).coerceIn(0L, duration)
        seekTo(target)
    }

    fun toggleSnapping() {
        _snappingEnabled.value = !_snappingEnabled.value
    }

    fun setPlaybackSpeed(speed: Float) {
        _playbackSpeed.value = speed
        player?.setPlaybackSpeed(speed)
    }

    fun selectLayer(layerId: String?) {
        _selectedLayerId.value = layerId
        val lyr = _project.value?.compositions?.firstOrNull()?.layers?.find { it.layerId == layerId }
        lyr?.textData?.let { td ->
            _activeTextContent.value = td.text
            _activeFontPath.value = td.fontPath
            _activeFontName.value = td.fontName
            _activeTextColor.value = td.colorHex
            _activeFontSize.value = td.fontSize
        }
    }

    /**
     * Adds an extra layer to the composition (Text, Audio, Sticker/Shape, Video, Adjustment).
     */
    fun addExtraLayer(type: String, title: String = "") {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        saveSnapshot()

        val durationMs = comp.durationMs.coerceAtLeast(15000L)
        val newLayerId = "lyr_${type.lowercase()}_${System.currentTimeMillis() % 10000}"

        val newLayer = when (type.uppercase()) {
            "TEXT" -> JsxPresetEngine.instantiatePreset("kinetic_title", durationMs).copy(
                layerId = newLayerId,
                type = "TEXT",
                name = if (title.isNotBlank()) title else "Video365 Motion Title",
                textData = TextData(
                    text = if (title.isNotBlank()) title else "NEW TITLE",
                    subtitleText = "Sub-headline text",
                    fontSize = 20f,
                    colorHex = "#06B6D4"
                )
            )
            "AUDIO", "MUSIC" -> Layer(
                layerId = newLayerId,
                type = "AUDIO",
                name = if (title.isNotBlank()) title else "Heaven in closer - Lalinea",
                assetId = "ast_audio_sample",
                inPointMs = 0,
                outPointMs = durationMs,
                textData = TextData(text = if (title.isNotBlank()) title else "Heaven in closer - Lalinea")
            )
            "SHAPE", "STICKER" -> JsxPresetEngine.instantiatePreset("lower_third", durationMs).copy(
                layerId = newLayerId,
                type = "SHAPE",
                name = if (title.isNotBlank()) title else "Sticker Badge",
                textData = TextData(
                    text = if (title.isNotBlank()) title else "Sticker Badge",
                    subtitleText = "Video365 Elements",
                    fontSize = 14f,
                    colorHex = "#F59E0B"
                )
            )
            "ADJUSTMENT" -> Layer(
                layerId = newLayerId,
                type = "ADJUSTMENT",
                name = if (title.isNotBlank()) title else "Cinematic Color Grade",
                inPointMs = 0,
                outPointMs = durationMs
            )
            else -> Layer(
                layerId = newLayerId,
                type = "VIDEO",
                name = if (title.isNotBlank()) title else "Video Overlay PiP",
                assetId = "ast_overlay_video",
                inPointMs = 0,
                outPointMs = durationMs
            )
        }

        val updatedComp = comp.copy(layers = comp.layers + newLayer)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        _selectedLayerId.value = newLayer.layerId
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Moves a layer horizontally across the timeline (modifies inPoint and outPoint by deltaMs).
     */
    fun moveLayer(layerId: String, deltaMs: Long) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val targetLayer = comp.layers.find { it.layerId == layerId } ?: return

        saveSnapshot()
        val duration = targetLayer.outPointMs - targetLayer.inPointMs
        val newInPoint = (targetLayer.inPointMs + deltaMs).coerceAtLeast(0L)
        val newOutPoint = newInPoint + duration

        val updatedLayers = comp.layers.map { lyr ->
            if (lyr.layerId == layerId) {
                lyr.copy(inPointMs = newInPoint, outPointMs = newOutPoint)
            } else lyr
        }

        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Trims a layer's start in-point.
     */
    fun trimLayerStart(layerId: String, newInPointMs: Long) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val targetLayer = comp.layers.find { it.layerId == layerId } ?: return

        saveSnapshot()
        val safeInPoint = newInPointMs.coerceIn(0L, targetLayer.outPointMs - 300L)
        val updatedLayers = comp.layers.map { lyr ->
            if (lyr.layerId == layerId) lyr.copy(inPointMs = safeInPoint) else lyr
        }

        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Trims a layer's end out-point.
     */
    fun trimLayerEnd(layerId: String, newOutPointMs: Long) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val targetLayer = comp.layers.find { it.layerId == layerId } ?: return

        saveSnapshot()
        val safeOutPoint = newOutPointMs.coerceAtLeast(targetLayer.inPointMs + 300L)
        val updatedLayers = comp.layers.map { lyr ->
            if (lyr.layerId == layerId) lyr.copy(outPointMs = safeOutPoint) else lyr
        }

        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Splits clip at current playhead position.
     */
    fun splitLayerAtPlayhead(layerId: String? = null) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val targetId = layerId ?: _selectedLayerId.value ?: comp.layers.firstOrNull()?.layerId ?: return
        val target = comp.layers.find { it.layerId == targetId } ?: return

        val playhead = _currentTimeMs.value
        if (playhead <= target.inPointMs + 200L || playhead >= target.outPointMs - 200L) {
            return
        }

        saveSnapshot()
        val originalOut = target.outPointMs
        val part1 = target.copy(outPointMs = playhead)
        val part2 = target.copy(
            layerId = "${target.layerId}_pt2_${System.currentTimeMillis() % 1000}",
            inPointMs = playhead,
            outPointMs = originalOut
        )

        val updatedLayers = mutableListOf<Layer>()
        comp.layers.forEach { lyr ->
            if (lyr.layerId == targetId) {
                updatedLayers.add(part1)
                updatedLayers.add(part2)
            } else {
                updatedLayers.add(lyr)
            }
        }

        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        _selectedLayerId.value = part2.layerId
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Clones/Duplicates the selected layer.
     */
    fun duplicateLayer(layerId: String) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val target = comp.layers.find { it.layerId == layerId } ?: return

        saveSnapshot()
        val clone = target.copy(
            layerId = "${target.layerId}_copy_${System.currentTimeMillis() % 1000}"
        )

        val updatedComp = comp.copy(layers = comp.layers + clone)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        _selectedLayerId.value = clone.layerId
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Deletes the specified layer.
     */
    fun deleteLayer(layerId: String) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        if (comp.layers.size <= 1) return

        saveSnapshot()
        val updatedLayers = comp.layers.filter { it.layerId != layerId }
        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        _selectedLayerId.value = updatedLayers.firstOrNull()?.layerId
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Changes layer stack Z-order.
     */
    fun reorderLayer(layerId: String, moveUp: Boolean) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val index = comp.layers.indexOfFirst { it.layerId == layerId }
        if (index == -1) return

        val newIndex = if (moveUp) index - 1 else index + 1
        if (newIndex !in comp.layers.indices) return

        saveSnapshot()
        val mutableList = comp.layers.toMutableList()
        val item = mutableList.removeAt(index)
        mutableList.add(newIndex, item)

        val updatedComp = comp.copy(layers = mutableList)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    fun toggleLayerVisibility(layerId: String) {
        val current = _hiddenLayerIds.value
        _hiddenLayerIds.value = if (current.contains(layerId)) {
            current - layerId
        } else {
            current + layerId
        }
    }

    fun toggleLayerMute(layerId: String) {
        val current = _mutedLayerIds.value
        _mutedLayerIds.value = if (current.contains(layerId)) {
            current - layerId
        } else {
            current + layerId
        }
    }

    fun selectFont(fontName: String, fontPath: String?) {
        _activeFontName.value = fontName
        _activeFontPath.value = fontPath
        _selectedLayerId.value?.let { id ->
            updateLayerText(layerId = id, fontName = fontName, fontPath = fontPath)
        }
    }

    fun updateTextContent(text: String) {
        _activeTextContent.value = text
        _selectedLayerId.value?.let { id ->
            updateLayerText(layerId = id, text = text)
        }
    }

    fun updateTextColor(hex: String) {
        _activeTextColor.value = hex
        _selectedLayerId.value?.let { id ->
            updateLayerText(layerId = id, colorHex = hex)
        }
    }

    fun updateFontSize(size: Float) {
        _activeFontSize.value = size
        _selectedLayerId.value?.let { id ->
            updateLayerText(layerId = id, fontSize = size)
        }
    }

    fun updateLayerText(
        layerId: String,
        text: String? = null,
        fontName: String? = null,
        fontPath: String? = null,
        colorHex: String? = null,
        fontSize: Float? = null
    ) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val target = comp.layers.find { it.layerId == layerId } ?: return

        val existingText = target.textData ?: TextData(text = target.layerId)
        val updatedTextData = existingText.copy(
            text = text ?: existingText.text,
            fontName = fontName ?: existingText.fontName,
            fontPath = fontPath ?: existingText.fontPath,
            colorHex = colorHex ?: existingText.colorHex,
            fontSize = fontSize ?: existingText.fontSize
        )

        val updatedLayer = target.copy(textData = updatedTextData)
        val updatedLayers = comp.layers.map { if (it.layerId == layerId) updatedLayer else it }
        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    fun createProject(name: String, ratio: String, width: Int, height: Int) {
        val projectId = "prj_${UUID.randomUUID().toString().take(8)}"
        val compId = "comp_main"
        val newProject = Video365Project(
            projectMeta = ProjectMeta(
                projectId = projectId,
                orientation = ratio,
                width = width,
                height = height,
                fps = 60.0,
                activeCompId = compId
            ),
            compositions = listOf(
                Composition(
                    compId = compId,
                    durationMs = 0
                )
            )
        )
        
        _project.value = newProject
        Video365Engine.updateProjectState(newProject)
    }

    fun seekTo(timeMs: Long) {
        _currentTimeMs.value = timeMs
        player?.seekTo(timeMs)
        Video365Engine.renderFrame(timeMs)
    }

    fun toggleDollyZoom() {
        _isDollyEnabled.value = !_isDollyEnabled.value
        if (!_isDollyEnabled.value) {
            Video365Engine.setDollyZoom(1.0f)
        }
    }

    fun applyTransition(name: String, progress: Float) {
        _activeTransition.value = name
        _transitionProgress.value = progress
        Video365Engine.setTransition(name, progress)
    }

    fun setExposure(value: Float) {
        _exposure.value = value
    }

    fun setContrast(value: Float) {
        _contrast.value = value
    }

    fun setSaturation(value: Float) {
        _saturation.value = value
    }

    fun setVignette(value: Float) {
        _vignette.value = value
    }

    fun setChromaKey(enabled: Boolean, threshold: Float) {
        _chromaKeyEnabled.value = enabled
        _chromaThreshold.value = threshold
    }

    fun cycleAspectRatio() {
        val current = _aspectRatio.value
        val next = when (current) {
            "9:16" -> "16:9"
            "16:9" -> "1:1"
            "1:1" -> "4:5"
            else -> "9:16"
        }
        setAspectRatio(next)
    }

    fun setAspectRatio(ratio: String) {
        _aspectRatio.value = ratio
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val (w, h) = when (ratio) {
            "16:9" -> 1920 to 1080
            "1:1" -> 1080 to 1080
            "4:5" -> 1080 to 1350
            else -> 1080 to 1920
        }
        val updatedMeta = current.projectMeta.copy(
            orientation = ratio,
            width = w,
            height = h
        )
        val updatedProject = current.copy(
            projectMeta = updatedMeta,
            compositions = listOf(comp)
        )
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    fun loadSampleProject(context: android.content.Context? = null, uri: Uri? = null, ratio: String = "9:16") {
        _aspectRatio.value = ratio
        val sampleProj = SampleVideo365Project.create(sampleVideoUri = uri, context = context, aspectRatio = ratio)
        _project.value = sampleProj
        Video365Engine.updateProjectState(sampleProj)
    }

    fun loadSampleProject(uri: Uri?) {
        loadSampleProject(null, uri, "9:16")
    }

    fun addPresetLayer(presetName: String) {
        val current = _project.value ?: return
        val layer = JsxPresetEngine.instantiatePreset(presetName)
        val comp = current.compositions.firstOrNull() ?: return
        val updatedComp = comp.copy(layers = comp.layers + layer)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        _selectedLayerId.value = layer.layerId
        Video365Engine.updateProjectState(updatedProject)
    }

    fun setDollyZoom(zoom: Float) {
        if (_isDollyEnabled.value) {
            Video365Engine.setDollyZoom(zoom)
        }
    }

    override fun onCleared() {
        super.onCleared()
        playbackTickerJob?.cancel()
    }
}
