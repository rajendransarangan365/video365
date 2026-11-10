package com.tharunbirla.librecuts.engine

import android.content.Context
import android.net.Uri
import com.tharunbirla.librecuts.models.v2.*
import java.io.File

/**
 * Creates a complete After Effects & Premiere Pro-grade sample project for Video365.
 * Demonstrates:
 * - Multi-track layer compositing
 * - C++ GLSL Transitions (Whip Pan, Glitch, Dissolve, Doorway 3D, Zoom)
 * - AE Expression Evaluator (wiggle(3.0, 25.0))
 * - Lumetri Color Grading Adjustment Layer
 * - Motion Graphics Animated Title & Lower Third (Bézier interpolation)
 * - Smart 5s Segment Pre-render Caching ("Render on the Go")
 */
object SampleVideo365Project {

    fun getOrExtractSampleVideo(context: Context): Uri {
        val target = File(context.filesDir, "sample_video365.mp4")
        if (!target.exists() || target.length() < 1000) {
            try {
                context.assets.open("sample_video365.mp4").use { input ->
                    target.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e("SampleVideo365Project", "Could not extract sample video from assets", e)
            }
        }
        return Uri.fromFile(target)
    }

    fun create(sampleVideoUri: Uri? = null, context: Context? = null, aspectRatio: String = "9:16"): Video365Project {
        val uriStr = sampleVideoUri?.toString()
            ?: if (context != null) getOrExtractSampleVideo(context).toString() else "file:///data/local/tmp/sample_video365.mp4"
        val durationMs = 15000L

        val orientationStr = when (aspectRatio) {
            "HORIZONTAL_16_9", "16:9" -> "HORIZONTAL_16_9"
            "SQUARE_1_1", "1:1" -> "SQUARE_1_1"
            "PORTRAIT_4_5", "4:5" -> "PORTRAIT_4_5"
            else -> "VERTICAL_9_16"
        }

        val (compWidth, compHeight) = when (aspectRatio) {
            "HORIZONTAL_16_9", "16:9" -> 1920 to 1080
            "SQUARE_1_1", "1:1" -> 1080 to 1080
            "PORTRAIT_4_5", "4:5" -> 1080 to 1350
            else -> 1080 to 1920
        }

        val titleLayer = JsxPresetEngine.instantiatePreset("kinetic_title", 10000L).copy(
            layerId = "lyr_mo_title",
            name = "Motion Title",
            textData = TextData(
                text = "VIDEO365 STUDIO",
                subtitleText = "MOTION GRAPHICS & COMPOSITING",
                fontSize = 20f,
                colorHex = "#FFFFFF"
            ),
            transform = Transform(
                position = AnimatablePropertyVector3(
                    staticValue = listOf(540.0f, 600.0f, 0.0f),
                    expression = "wiggle(3.0, 25.0)",
                    expressionEnabled = true,
                    keyframes = listOf(
                        KeyframeVector3(0, listOf(540.0f, 300.0f, 0.0f), "BEZIER", listOf(0.2f, 0.1f), listOf(0.2f, 1.0f)),
                        KeyframeVector3(1000, listOf(540.0f, 600.0f, 0.0f), "BEZIER", listOf(0.2f, 0.1f), listOf(0.2f, 1.0f))
                    )
                ),
                scale = AnimatablePropertyVector3(
                    staticValue = listOf(1.0f, 1.0f, 1.0f),
                    keyframes = listOf(
                        KeyframeVector3(0, listOf(0.0f, 0.0f, 1.0f), "BEZIER"),
                        KeyframeVector3(800, listOf(1.1f, 1.1f, 1.0f), "BEZIER"),
                        KeyframeVector3(1000, listOf(1.0f, 1.0f, 1.0f), "LINEAR")
                    )
                ),
                opacity = AnimatablePropertyFloat(staticValue = 1.0f)
            )
        )

        val lowerThirdLayer = JsxPresetEngine.instantiatePreset("lower_third", 12000L).copy(
            layerId = "lyr_mo_lower_third",
            name = "Lower Third Accent",
            textData = TextData(
                text = "SARANGAN RAJENDRAN",
                subtitleText = "VIDEO ARCHITECT & DIRECTOR",
                fontSize = 14f,
                colorHex = "#FFFFFF"
            )
        )

        val videoLayer = Layer(
            layerId = "lyr_main_video",
            type = "VIDEO",
            name = "Main Sequence (4K UHD)",
            assetId = "ast_video365_01",
            inPointMs = 0,
            outPointMs = durationMs,
            transform = Transform(
                position = AnimatablePropertyVector3(staticValue = listOf(540.0f, 960.0f, 0.0f)),
                scale = AnimatablePropertyVector3(staticValue = listOf(1.0f, 1.0f, 1.0f)),
                opacity = AnimatablePropertyFloat(staticValue = 1.0f)
            ),
            transitionOut = Transition(
                transitionId = "whip_pan",
                durationMs = 600,
                adjusterParams = mapOf(
                    "directionAngle" to "90.0",
                    "chromaticAberration" to "0.3"
                )
            )
        )

        val adjustmentLayer = Layer(
            layerId = "lyr_adjustment_color",
            type = "ADJUSTMENT",
            name = "Cinematic Color Grade",
            inPointMs = 0,
            outPointMs = durationMs,
            transform = Transform(position = AnimatablePropertyVector3(staticValue = listOf(540.0f, 960.0f, 0.0f))),
            effects = listOf(
                Effect(
                    effectId = "fx_lumetri_grade",
                    shaderName = "glsl_lumetri_color",
                    params = mapOf(
                        "uExposure" to "0.25",
                        "uContrast" to "1.15",
                        "uSaturation" to "1.2",
                        "uTint" to "1.05, 1.0, 0.95" // Warm cinematic tone
                    )
                ),
                Effect(
                    effectId = "fx_vignette",
                    shaderName = "glsl_vignette",
                    params = mapOf("uRadius" to "0.8", "uSoftness" to "0.4")
                )
            )
        )

        val audioLayer1 = Layer(
            layerId = "lyr_audio_main",
            type = "AUDIO",
            name = "Heaven in closer - Lalinea",
            assetId = "ast_audio_01",
            inPointMs = 0,
            outPointMs = durationMs,
            textData = TextData(
                text = "Heaven in closer - Lalinea",
                subtitleText = "Original Audio - 320kbps",
                fontSize = 11f,
                colorHex = "#3B82F6"
            )
        )

        val audioLayer2 = Layer(
            layerId = "lyr_audio_sfx",
            type = "AUDIO",
            name = "Heaven in closer - Lalinea",
            assetId = "ast_audio_02",
            inPointMs = 0,
            outPointMs = durationMs,
            textData = TextData(
                text = "Heaven in closer - Lalinea",
                subtitleText = "Ambient Beat FX",
                fontSize = 11f,
                colorHex = "#F59E0B"
            )
        )

        val composition = Composition(
            compId = "comp_main_demo",
            durationMs = durationMs,
            layers = listOf(adjustmentLayer, titleLayer, lowerThirdLayer, videoLayer, audioLayer1),
            renderCacheSegments = listOf(
                RenderCacheSegment("seg_0_5000", 0, 5000, "sha256_mock_01", "file:///cache/seg_0.mp4", true),
                RenderCacheSegment("seg_5000_10000", 5000, 10000, "sha256_mock_02", "file:///cache/seg_1.mp4", true),
                RenderCacheSegment("seg_10000_15000", 10000, 15000, "sha256_mock_03", "file:///cache/seg_2.mp4", true)
            )
        )

        return Video365Project(
            schemaVersion = "2.0.0",
            projectMeta = ProjectMeta(
                projectId = "proj_video365_demo",
                orientation = orientationStr,
                width = compWidth,
                height = compHeight,
                fps = 60.0,
                thermalPolicy = "AUTO_PROXY_AND_SEGMENT_CACHE",
                activeCompId = "comp_main_demo"
            ),
            assets = listOf(
                Asset(
                    assetId = "ast_video365_01",
                    type = "VIDEO",
                    sourceUri = uriStr,
                    proxyUri = uriStr
                )
            ),
            compositions = listOf(composition)
        )
    }
}
