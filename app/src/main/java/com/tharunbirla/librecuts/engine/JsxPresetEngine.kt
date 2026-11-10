package com.tharunbirla.librecuts.engine

import com.tharunbirla.librecuts.models.v2.*

/**
 * Parses and instantiates JSX-style declarative Motion Graphics templates
 * into Video365 v2 Composition Layers.
 *
 * Example JSX:
 * /** @jsx Video365.createElement */
 * <TitleLayer text="BREAKING NEWS" font="Bold" color="#FFCC00">
 *     <Transform position={[540, 800, 0]} expression="wiggle(3.0, 20.0)" />
 *     <Animation inPointMs={0} outPointMs={5000} />
 * </TitleLayer>
 */
object JsxPresetEngine {

    /**
     * Loads a pre-built or custom JSX motion graphics preset.
     */
    fun instantiatePreset(presetName: String, durationMs: Long = 5000L): Layer {
        return when (presetName.lowercase()) {
            "kinetic_title", "title" -> createKineticTitle(durationMs)
            "lower_third" -> createLowerThird(durationMs)
            "social_callout" -> createSocialCallout(durationMs)
            "glitch_intro" -> createGlitchIntro(durationMs)
            else -> createKineticTitle(durationMs)
        }
    }

    private fun createKineticTitle(durationMs: Long): Layer {
        return Layer(
            layerId = "lyr_title_${System.currentTimeMillis() % 10000}",
            type = "TEXT",
            inPointMs = 0,
            outPointMs = durationMs,
            transform = Transform(
                position = AnimatablePropertyVector3(
                    staticValue = listOf(540.0f, 960.0f, 0.0f),
                    expression = "wiggle(2.5, 25.0)",
                    expressionEnabled = true,
                    keyframes = listOf(
                        KeyframeVector3(0, listOf(540.0f, 1100.0f, 0.0f), "BEZIER", listOf(0.25f, 0.1f), listOf(0.25f, 1.0f)),
                        KeyframeVector3(800, listOf(540.0f, 960.0f, 0.0f), "BEZIER", listOf(0.25f, 0.1f), listOf(0.25f, 1.0f))
                    )
                ),
                scale = AnimatablePropertyVector3(
                    staticValue = listOf(1.0f, 1.0f, 1.0f),
                    keyframes = listOf(
                        KeyframeVector3(0, listOf(0.5f, 0.5f, 1.0f), "BEZIER"),
                        KeyframeVector3(800, listOf(1.0f, 1.0f, 1.0f), "LINEAR")
                    )
                ),
                opacity = AnimatablePropertyFloat(
                    staticValue = 1.0f,
                    keyframes = listOf(
                        KeyframeFloat(0, 0.0f),
                        KeyframeFloat(400, 1.0f)
                    )
                )
            ),
            effects = listOf(
                Effect(
                    effectId = "fx_chroma",
                    shaderName = "glsl_chromatic_aberration",
                    params = mapOf("uAmount" to "0.3")
                )
            )
        )
    }

    private fun createLowerThird(durationMs: Long): Layer {
        return Layer(
            layerId = "lyr_l3rd_${System.currentTimeMillis() % 10000}",
            type = "SHAPE",
            inPointMs = 0,
            outPointMs = durationMs,
            transform = Transform(
                position = AnimatablePropertyVector3(
                    staticValue = listOf(540.0f, 1600.0f, 0.0f),
                    keyframes = listOf(
                        KeyframeVector3(0, listOf(1500.0f, 1600.0f, 0.0f), "BEZIER", listOf(0.1f, 0.9f), listOf(0.2f, 1.0f)),
                        KeyframeVector3(600, listOf(540.0f, 1600.0f, 0.0f), "BEZIER", listOf(0.1f, 0.9f), listOf(0.2f, 1.0f))
                    )
                ),
                opacity = AnimatablePropertyFloat(staticValue = 0.9f)
            ),
            effects = listOf(
                Effect(
                    effectId = "fx_lumetri",
                    shaderName = "glsl_lumetri_color",
                    params = mapOf("uExposure" to "0.2", "uContrast" to "1.1")
                )
            )
        )
    }

    private fun createSocialCallout(durationMs: Long): Layer {
        return Layer(
            layerId = "lyr_social_${System.currentTimeMillis() % 10000}",
            type = "SHAPE",
            inPointMs = 500,
            outPointMs = durationMs,
            transform = Transform(
                position = AnimatablePropertyVector3(
                    staticValue = listOf(540.0f, 1750.0f, 0.0f),
                    expression = "wiggle(1.5, 10.0)",
                    expressionEnabled = true
                ),
                scale = AnimatablePropertyVector3(
                    staticValue = listOf(1.0f, 1.0f, 1.0f),
                    keyframes = listOf(
                        KeyframeVector3(500, listOf(0.0f, 0.0f, 1.0f), "BEZIER"),
                        KeyframeVector3(900, listOf(1.1f, 1.1f, 1.0f), "BEZIER"),
                        KeyframeVector3(1100, listOf(1.0f, 1.0f, 1.0f), "LINEAR")
                    )
                )
            )
        )
    }

    private fun createGlitchIntro(durationMs: Long): Layer {
        return Layer(
            layerId = "lyr_glitch_${System.currentTimeMillis() % 10000}",
            type = "VIDEO",
            inPointMs = 0,
            outPointMs = durationMs,
            transitionOut = Transition(
                transitionId = "glitch",
                durationMs = 600
            ),
            effects = listOf(
                Effect(
                    effectId = "fx_glitch",
                    shaderName = "glsl_chromatic_aberration",
                    params = mapOf("uAmount" to "0.8")
                )
            )
        )
    }
}
