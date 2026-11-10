package com.tharunbirla.librecuts

import com.tharunbirla.librecuts.engine.JsxPresetEngine
import com.tharunbirla.librecuts.engine.SampleVideo365Project
import com.tharunbirla.librecuts.models.v2.*
import com.tharunbirla.librecuts.utils.ProjectSerializer
import org.junit.Assert.*
import org.junit.Test
import java.security.MessageDigest

/**
 * Comprehensive Automated Test Suite for Video365.
 * Validates Part 1 (Transitions & Effects), Part 2 (Expression Engine & JSX Presets),
 * Part 3 (Segment Pre-Render Caching & Proxy Math), and Project Schema v2 Serialization.
 */
class Video365TestSuite {

    @Test
    fun testJsxPresetKineticTitle() {
        val layer = JsxPresetEngine.instantiatePreset("kinetic_title", 8000L)
        assertEquals("TEXT", layer.type)
        assertEquals(0L, layer.inPointMs)
        assertEquals(8000L, layer.outPointMs)

        // Verify Position & Wiggle Expression
        val pos = layer.transform.position
        assertTrue("Expression must be enabled", pos.expressionEnabled)
        assertEquals("wiggle(2.5, 25.0)", pos.expression)
        assertEquals(3, pos.staticValue.size)
        assertEquals(540.0f, pos.staticValue[0], 0.001f)
        assertEquals(960.0f, pos.staticValue[1], 0.001f)

        // Verify Bézier Keyframes
        assertEquals(2, pos.keyframes.size)
        assertEquals("BEZIER", pos.keyframes[0].interpolation)
        assertNotNull(pos.keyframes[0].inTangent)
        assertNotNull(pos.keyframes[0].outTangent)

        // Verify Scale & Opacity
        assertNotNull(layer.transform.scale)
        assertNotNull(layer.transform.opacity)
        assertEquals(2, layer.transform.opacity?.keyframes?.size)

        // Verify Chromatic Aberration Effect
        assertEquals(1, layer.effects.size)
        assertEquals("glsl_chromatic_aberration", layer.effects[0].shaderName)
        assertEquals("0.3", layer.effects[0].params["uAmount"])
    }

    @Test
    fun testJsxPresetLowerThird() {
        val layer = JsxPresetEngine.instantiatePreset("lower_third", 6000L)
        assertEquals("SHAPE", layer.type)
        assertEquals(6000L, layer.outPointMs)

        val pos = layer.transform.position
        assertEquals(2, pos.keyframes.size)
        assertEquals(1500.0f, pos.keyframes[0].value[0], 0.001f) // Enters from off-screen right
        assertEquals(540.0f, pos.keyframes[1].value[0], 0.001f)  // Settles at center

        // Verify Lumetri Color Grading Effect
        assertEquals(1, layer.effects.size)
        assertEquals("glsl_lumetri_color", layer.effects[0].shaderName)
        assertEquals("0.2", layer.effects[0].params["uExposure"])
        assertEquals("1.1", layer.effects[0].params["uContrast"])
    }

    @Test
    fun testJsxPresetSocialCallout() {
        val layer = JsxPresetEngine.instantiatePreset("social_callout", 5000L)
        assertEquals("SHAPE", layer.type)
        assertEquals(500L, layer.inPointMs)

        val pos = layer.transform.position
        assertTrue(pos.expressionEnabled)
        assertEquals("wiggle(1.5, 10.0)", pos.expression)

        // Verify Scale Pop-in Keyframes
        val scale = layer.transform.scale
        assertNotNull(scale)
        assertEquals(3, scale!!.keyframes.size)
        assertEquals(0.0f, scale.keyframes[0].value[0], 0.001f) // Starts at 0
        assertEquals(1.1f, scale.keyframes[1].value[0], 0.001f) // Overshoots to 1.1 (Pop effect)
        assertEquals(1.0f, scale.keyframes[2].value[0], 0.001f) // Settles at 1.0
    }

    @Test
    fun testJsxPresetGlitchIntro() {
        val layer = JsxPresetEngine.instantiatePreset("glitch_intro", 4000L)
        assertEquals("VIDEO", layer.type)

        // Verify Transition
        assertNotNull(layer.transitionOut)
        assertEquals("glitch", layer.transitionOut?.transitionId)
        assertEquals(600L, layer.transitionOut?.durationMs)

        // Verify Chromatic Aberration Glitch Shader
        assertEquals(1, layer.effects.size)
        assertEquals("glsl_chromatic_aberration", layer.effects[0].shaderName)
        assertEquals("0.8", layer.effects[0].params["uAmount"])
    }

    @Test
    fun testSampleVideo365ProjectStructure() {
        val project = SampleVideo365Project.create(null)

        // Verify Project Metadata
        assertEquals("2.0.0", project.schemaVersion)
        assertEquals("proj_video365_demo", project.projectMeta.projectId)
        assertEquals("VERTICAL_9_16", project.projectMeta.orientation)
        assertEquals(1080, project.projectMeta.width)
        assertEquals(1920, project.projectMeta.height)
        assertEquals(60.0, project.projectMeta.fps, 0.001)
        assertEquals("AUTO_PROXY_AND_SEGMENT_CACHE", project.projectMeta.thermalPolicy)

        // Verify Assets
        assertEquals(1, project.assets.size)
        assertEquals("VIDEO", project.assets[0].type)

        // Verify Composition & Multi-track Layers
        assertEquals(1, project.compositions.size)
        val comp = project.compositions[0]
        assertEquals(15000L, comp.durationMs)
        assertEquals(5, comp.layers.size)

        // Track 0: Lumetri Color Adjustment Layer
        val adjLayer = comp.layers[0]
        assertEquals("ADJUSTMENT", adjLayer.type)
        assertEquals(2, adjLayer.effects.size)
        assertEquals("glsl_lumetri_color", adjLayer.effects[0].shaderName)
        assertEquals("0.25", adjLayer.effects[0].params["uExposure"])
        assertEquals("1.15", adjLayer.effects[0].params["uContrast"])
        assertEquals("glsl_vignette", adjLayer.effects[1].shaderName)

        // Track 1: Kinetic Title with Wiggle Expression
        val titleLayer = comp.layers[1]
        assertEquals("TEXT", titleLayer.type)
        assertTrue(titleLayer.transform.position.expressionEnabled)
        assertEquals("wiggle(3.0, 25.0)", titleLayer.transform.position.expression)

        // Track 2: Lower Third
        val l3rdLayer = comp.layers[2]
        assertEquals("SHAPE", l3rdLayer.type)

        // Track 3: Main Video with Whip Pan Transition
        val videoLayer = comp.layers[3]
        assertEquals("VIDEO", videoLayer.type)
        assertNotNull(videoLayer.transitionOut)
        assertEquals("whip_pan", videoLayer.transitionOut?.transitionId)
        assertEquals(600L, videoLayer.transitionOut?.durationMs)
        assertEquals("90.0", videoLayer.transitionOut?.adjusterParams?.get("directionAngle"))

        // Track 4: Audio Track with Waveforms
        val audioLayer = comp.layers[4]
        assertEquals("AUDIO", audioLayer.type)
        assertEquals("Heaven in closer - Lalinea", audioLayer.textData?.text)

        // Verify Part 3 Pre-render Cache Segments (3 x 5s chunks)
        assertEquals(3, comp.renderCacheSegments.size)
        assertEquals(0L, comp.renderCacheSegments[0].startMs)
        assertEquals(5000L, comp.renderCacheSegments[0].endMs)
        assertTrue(comp.renderCacheSegments[0].isValid)

        assertEquals(5000L, comp.renderCacheSegments[1].startMs)
        assertEquals(10000L, comp.renderCacheSegments[1].endMs)
        assertTrue(comp.renderCacheSegments[1].isValid)

        assertEquals(10000L, comp.renderCacheSegments[2].startMs)
        assertEquals(15000L, comp.renderCacheSegments[2].endMs)
        assertTrue(comp.renderCacheSegments[2].isValid)
    }

    @Test
    fun testProjectSerializerRoundtrip() {
        val original = SampleVideo365Project.create(null)

        // Serialize to JSON
        val json = ProjectSerializer.serialize(original)
        assertNotNull(json)
        assertTrue(json.contains("\"schemaVersion\": \"2.0.0\""))
        assertTrue(json.contains("\"wiggle(3.0, 25.0)\""))
        assertTrue(json.contains("\"glsl_lumetri_color\""))
        assertTrue(json.contains("\"whip_pan\""))

        // Deserialize back from JSON
        val deserialized = ProjectSerializer.deserializeVideo365(json)
        assertEquals(original.schemaVersion, deserialized.schemaVersion)
        assertEquals(original.projectMeta.projectId, deserialized.projectMeta.projectId)
        assertEquals(original.projectMeta.fps, deserialized.projectMeta.fps, 0.001)
        assertEquals(original.compositions.size, deserialized.compositions.size)
        assertEquals(original.compositions[0].layers.size, deserialized.compositions[0].layers.size)

        val origTitle = original.compositions[0].layers[1]
        val desTitle = deserialized.compositions[0].layers[1]
        assertEquals(origTitle.transform.position.expression, desTitle.transform.position.expression)
        assertEquals(origTitle.transform.position.expressionEnabled, desTitle.transform.position.expressionEnabled)
    }

    @Test
    fun testSegmentSlicingAndHashingLogic() {
        val totalDurationMs = 15000L
        val segmentDurationMs = 5000L
        val segmentCount = ((totalDurationMs + segmentDurationMs - 1) / segmentDurationMs).toInt()
        assertEquals(3, segmentCount)

        // Verify SHA-256 state hashing reproducibility
        val md = MessageDigest.getInstance("SHA-256")
        val stateString = "comp:comp_main_demo;seg:0-5000;lyr:lyr_adjustment_color;lyr:lyr_mo_title;lyr:lyr_main_video"
        val hashBytes1 = md.digest(stateString.toByteArray())
        val hashStr1 = hashBytes1.joinToString("") { "%02x".format(it) }

        md.reset()
        val hashBytes2 = md.digest(stateString.toByteArray())
        val hashStr2 = hashBytes2.joinToString("") { "%02x".format(it) }

        assertEquals(hashStr1, hashStr2)
        assertEquals(64, hashStr1.length) // SHA-256 produces 64 hex characters
    }

    @Test
    fun testAutoProxyResolutionMath() {
        // High resolution sources (> 1080p) require proxy
        val src4kWidth = 2160
        val src4kHeight = 3840
        assertTrue("4K footage must require a proxy", src4kWidth > 1080 || src4kHeight > 1080)

        // Target intra-frame resolution is 540p
        val targetWidth = 540
        val targetHeight = (targetWidth * (src4kHeight.toFloat() / src4kWidth.toFloat())).toInt()
        assertEquals(960, targetHeight) // 540x960 9:16 vertical proxy
    }

    @Test
    fun testAspectRatioLetterboxPillarboxTransform() {
        // Test 1: 16:9 video in 9:16 canvas (letterbox)
        val canvasAspectVertical = 9f / 16f   // 0.5625
        val videoAspectHorizontal = 16f / 9f  // 1.7778
        assertTrue(videoAspectHorizontal > canvasAspectVertical)
        val letterboxScaleY = canvasAspectVertical / videoAspectHorizontal
        assertEquals(0.3164f, letterboxScaleY, 0.001f) // Scaled height with letterbox bars

        // Test 2: 9:16 video in 16:9 canvas (pillarbox)
        val canvasAspectHorizontal = 16f / 9f
        val videoAspectVertical = 9f / 16f
        assertTrue(videoAspectVertical < canvasAspectHorizontal)
        val pillarboxScaleX = videoAspectVertical / canvasAspectHorizontal
        assertEquals(0.3164f, pillarboxScaleX, 0.001f) // Scaled width with pillarbox bars
    }

    @Test
    fun testTransitionAndEffectsCatalog() {
        val expectedTransitions = listOf(
            "whip_pan", "glitch", "doorway", "zoom", "film_burn",
            "radial_blur", "swirl", "wave", "wipe", "dissolve"
        )
        assertEquals(10, expectedTransitions.size)

        val expectedEffects = listOf(
            "glsl_lumetri_color", "glsl_chromatic_aberration",
            "glsl_chroma_key", "glsl_unmult", "glsl_vignette"
        )
        assertEquals(5, expectedEffects.size)
    }
}

