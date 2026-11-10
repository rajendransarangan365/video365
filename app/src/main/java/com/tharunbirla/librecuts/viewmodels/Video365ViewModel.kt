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
import kotlinx.coroutines.launch
import java.util.UUID

class Video365ViewModel : ViewModel() {
    private val _project = MutableStateFlow<Video365Project?>(null)
    val project: StateFlow<Video365Project?> = _project.asStateFlow()

    private val _currentTimeMs = MutableStateFlow(0L)
    val currentTimeMs: StateFlow<Long> = _currentTimeMs.asStateFlow()

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

    fun addAsset(uri: String, type: String) {
        val current = _project.value ?: return
        val assetId = "ast_${UUID.randomUUID().toString().take(8)}"
        
        val newAsset = Asset(
            assetId = assetId,
            type = type,
            sourceUri = uri
        )
        
        val updatedProject = current.copy(
            assets = current.assets + newAsset
        )
        
        val comp = updatedProject.compositions.first()
        val layerId = "lyr_${UUID.randomUUID().toString().take(8)}"
        
        // Add a layer with a "Wiggle" expression example for Phase 1 demo
        val newLayer = Layer(
            layerId = layerId,
            type = type,
            assetId = assetId,
            inPointMs = 0,
            outPointMs = 10000,
            transform = Transform(
                position = AnimatablePropertyVector3(
                    staticValue = listOf(540f, 960f, 0f),
                    expression = "wiggle(2, 30)",
                    expressionEnabled = true
                )
            )
        )
        
        val updatedComp = comp.copy(layers = comp.layers + newLayer, durationMs = 10000)
        val finalProject = updatedProject.copy(
            compositions = listOf(updatedComp)
        )
        
        _project.value = finalProject
        Video365Engine.updateProjectState(finalProject)
    }
    
    fun seekTo(timeMs: Long) {
        _currentTimeMs.value = timeMs
        Video365Engine.renderFrame(timeMs)
    }

    fun toggleDollyZoom() {
        _isDollyEnabled.value = !_isDollyEnabled.value
        // If disabled, reset zoom in NDK
        if (!_isDollyEnabled.value) {
            Video365Engine.setDollyZoom(1.0f)
        }
    }

    fun applyGlitch() {
        Video365Engine.setTransition("glitch", 0.5f)
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

    var player: com.google.android.exoplayer2.ExoPlayer? = null

    fun attachPlayer(p: com.google.android.exoplayer2.ExoPlayer) {
        player = p
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
        Video365Engine.updateProjectState(updatedProject)
    }

    fun setDollyZoom(zoom: Float) {
        if (_isDollyEnabled.value) {
            Video365Engine.setDollyZoom(zoom)
        }
    }
}
