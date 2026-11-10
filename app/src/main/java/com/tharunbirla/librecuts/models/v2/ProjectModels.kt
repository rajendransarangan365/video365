package com.tharunbirla.librecuts.models.v2

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class Video365Project(
    val schemaVersion: String = "2.0.0",
    val projectMeta: ProjectMeta,
    val assets: List<Asset> = emptyList(),
    val compositions: List<Composition> = emptyList()
)

@Serializable
data class ProjectMeta(
    val projectId: String,
    val orientation: String, // VERTICAL_9_16, HORIZONTAL_16_9, etc.
    val width: Int,
    val height: Int,
    val fps: Double,
    val thermalPolicy: String = "AUTO_PROXY_AND_SEGMENT_CACHE",
    val activeCompId: String
)

@Serializable
data class Asset(
    val assetId: String,
    val type: String, // VIDEO, IMAGE, AUDIO
    val sourceUri: String,
    val proxyUri: String? = null,
    val transcript: List<TranscriptWord> = emptyList()
)

@Serializable
data class TranscriptWord(
    val word: String,
    val startMs: Long,
    val endMs: Long,
    val deleted: Boolean = false
)

@Serializable
data class Composition(
    val compId: String,
    val durationMs: Long,
    val cropToLayerBounds: Boolean = false,
    val renderCacheSegments: List<RenderCacheSegment> = emptyList(),
    val layers: List<Layer> = emptyList()
)

@Serializable
data class RenderCacheSegment(
    val segmentId: String,
    val startMs: Long,
    val endMs: Long,
    val stateHash: String,
    val cacheUri: String,
    val isValid: Boolean
)

@Serializable
data class TextData(
    val text: String = "VIDEO365 STUDIO",
    val fontPath: String? = null,
    val fontName: String = "Default",
    val fontSize: Float = 22f,
    val colorHex: String = "#FFFFFF",
    val subtitleText: String? = "MOTION GRAPHICS & COMPOSITING"
)

@Serializable
data class Layer(
    val layerId: String,
    val type: String, // VIDEO, IMAGE, TEXT, SHAPE, AUDIO, ADJUSTMENT
    val assetId: String? = null,
    val parentId: String? = null,
    val is3D: Boolean = false,
    val inPointMs: Long,
    val outPointMs: Long,
    val transform: Transform = Transform(position = AnimatablePropertyVector3(staticValue = listOf(0f, 0f, 0f))),
    val masks: List<Mask> = emptyList(),
    val effects: List<Effect> = emptyList(),
    val transitionOut: Transition? = null,
    val audioChain: AudioChain? = null,
    val textData: TextData? = null
)

@Serializable
data class Transform(
    val position: AnimatablePropertyVector3 = AnimatablePropertyVector3(staticValue = listOf(0f, 0f, 0f)),
    val scale: AnimatablePropertyVector3? = null,
    val rotation: AnimatablePropertyVector3? = null,
    val anchorPoint: AnimatablePropertyVector3? = null,
    val opacity: AnimatablePropertyFloat? = null
)

@Serializable
data class AnimatablePropertyVector3(
    val staticValue: List<Float>,
    val expression: String? = null,
    val expressionEnabled: Boolean = false,
    val keyframes: List<KeyframeVector3> = emptyList()
)

@Serializable
data class AnimatablePropertyFloat(
    val staticValue: Float,
    val expression: String? = null,
    val expressionEnabled: Boolean = false,
    val keyframes: List<KeyframeFloat> = emptyList()
)

@Serializable
data class KeyframeVector3(
    val timeMs: Long,
    val value: List<Float>,
    val interpolation: String = "BEZIER",
    val inTangent: List<Float>? = null,
    val outTangent: List<Float>? = null
)

@Serializable
data class KeyframeFloat(
    val timeMs: Long,
    val value: Float,
    val interpolation: String = "BEZIER",
    val inTangent: List<Float>? = null,
    val outTangent: List<Float>? = null
)

@Serializable
data class Mask(
    val maskId: String,
    val mode: String, // ADD, SUBTRACT, INTERSECT
    val type: String, // PATH, AI_ROTO_OBJECT
    val featherPx: Float,
    val trackedSplineKeyframes: List<JsonElement> = emptyList()
)

@Serializable
data class Effect(
    val effectId: String,
    val shaderName: String,
    val params: Map<String, String> = emptyMap()
)

@Serializable
data class Transition(
    val transitionId: String,
    val durationMs: Long,
    val adjusterParams: Map<String, String> = emptyMap()
)

@Serializable
data class AudioChain(
    val enhanceSpeechAI: Boolean = false,
    val gateThresholdDb: Float = -42.0f,
    val compressorRatio: Float = 4.0f,
    val distortionDrive: Float = 0.0f
)
