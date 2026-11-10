package com.tharunbirla.librecuts.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import android.net.Uri
import com.tharunbirla.librecuts.Video365Engine
import com.tharunbirla.librecuts.engine.JsxPresetEngine
import com.tharunbirla.librecuts.engine.SampleVideo365Project
import com.tharunbirla.librecuts.models.v2.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.UUID

/**
 * Primary ViewModel driving Video365 desktop & mobile workspace.
 * Provides timeline scrubbing, multi-track layer movement/trimming,
 * layer visibility & mute toggling, Z-order reordering,
 * and custom font/typography management.
 */
class Video365ViewModel : ViewModel() {
    private val _project = MutableStateFlow<Video365Project?>(null)
    val project: StateFlow<Video365Project?> = _project.asStateFlow()

    private val _currentTimeMs = MutableStateFlow(0L)
    val currentTimeMs: StateFlow<Long> = _currentTimeMs.asStateFlow()

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

    var player: com.google.android.exoplayer2.ExoPlayer? = null

    fun attachPlayer(p: com.google.android.exoplayer2.ExoPlayer) {
        player = p
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
     * Moves a layer horizontally across the timeline (modifies inPoint and outPoint by deltaMs).
     */
    fun moveLayer(layerId: String, deltaMs: Long) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val targetLayer = comp.layers.find { it.layerId == layerId } ?: return

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
        if (comp.layers.size <= 1) return // Keep at least one track

        val updatedLayers = comp.layers.filter { it.layerId != layerId }
        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        _selectedLayerId.value = updatedLayers.firstOrNull()?.layerId
        Video365Engine.updateProjectState(updatedProject)
    }

    /**
     * Changes layer stack Z-order (Move Up/Down in Adobe After Effects / Premiere layer stack).
     */
    fun reorderLayer(layerId: String, moveUp: Boolean) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val index = comp.layers.indexOfFirst { it.layerId == layerId }
        if (index == -1) return

        val newIndex = if (moveUp) index - 1 else index + 1
        if (newIndex !in comp.layers.indices) return

        val mutableList = comp.layers.toMutableList()
        val item = mutableList.removeAt(index)
        mutableList.add(newIndex, item)

        val updatedComp = comp.copy(layers = mutableList)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    fun toggleLayerVisibility(layerId: String) {
        val currentHidden = _hiddenLayerIds.value.toMutableSet()
        if (currentHidden.contains(layerId)) {
            currentHidden.remove(layerId)
        } else {
            currentHidden.add(layerId)
        }
        _hiddenLayerIds.value = currentHidden
    }

    fun toggleLayerMute(layerId: String) {
        val currentMuted = _mutedLayerIds.value.toMutableSet()
        val isNowMuted = if (currentMuted.contains(layerId)) {
            currentMuted.remove(layerId)
            false
        } else {
            currentMuted.add(layerId)
            true
        }
        _mutedLayerIds.value = currentMuted

        // If muting video layer, adjust player volume
        val targetLayer = _project.value?.compositions?.firstOrNull()?.layers?.find { it.layerId == layerId }
        if (targetLayer?.type == "VIDEO" || targetLayer?.type == "AUDIO") {
            player?.volume = if (isNowMuted) 0.0f else 1.0f
        }
    }

    /**
     * Updates typography and font on the active text layer.
     */
    fun selectFont(fontName: String, fontPath: String?) {
        _activeFontName.value = fontName
        _activeFontPath.value = fontPath

        val selId = _selectedLayerId.value ?: "lyr_mo_title"
        updateLayerText(selId, _activeTextContent.value, fontName = fontName, fontPath = fontPath)
    }

    fun updateTextContent(text: String) {
        _activeTextContent.value = text
        val selId = _selectedLayerId.value ?: "lyr_mo_title"
        updateLayerText(selId, text)
    }

    fun updateTextColor(hex: String) {
        _activeTextColor.value = hex
        val selId = _selectedLayerId.value ?: "lyr_mo_title"
        updateLayerText(selId, _activeTextContent.value, colorHex = hex)
    }

    fun updateFontSize(size: Float) {
        _activeFontSize.value = size
        val selId = _selectedLayerId.value ?: "lyr_mo_title"
        updateLayerText(selId, _activeTextContent.value, fontSize = size)
    }

    fun updateLayerText(
        layerId: String,
        text: String,
        subtitle: String? = null,
        fontName: String? = null,
        fontPath: String? = null,
        colorHex: String? = null,
        fontSize: Float? = null
    ) {
        val current = _project.value ?: return
        val comp = current.compositions.firstOrNull() ?: return
        val target = comp.layers.find { it.layerId == layerId } ?: return

        val existingText = target.textData ?: TextData()
        val updatedTextData = existingText.copy(
            text = text,
            subtitleText = subtitle ?: existingText.subtitleText,
            fontName = fontName ?: existingText.fontName,
            fontPath = fontPath ?: existingText.fontPath,
            colorHex = colorHex ?: existingText.colorHex,
            fontSize = fontSize ?: existingText.fontSize
        )

        val updatedLayers = comp.layers.map { lyr ->
            if (lyr.layerId == layerId) lyr.copy(textData = updatedTextData) else lyr
        }

        val updatedComp = comp.copy(layers = updatedLayers)
        val updatedProject = current.copy(compositions = listOf(updatedComp))
        _project.value = updatedProject
        Video365Engine.updateProjectState(updatedProject)
    }

    fun createProject(name: String, ratio: String, width: Int, height: Int) {
        val projectId = UUID.randomUUID().toString()
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

    fun loadSampleProject(context: android.content.Context? = null, uri: Uri? = null, ratio: String = "9:16") {
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
}
