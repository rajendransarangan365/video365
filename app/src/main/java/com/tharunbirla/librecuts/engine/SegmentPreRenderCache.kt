package com.tharunbirla.librecuts.engine

import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.util.Log
import com.tharunbirla.librecuts.models.v2.Composition
import com.tharunbirla.librecuts.models.v2.RenderCacheSegment
import java.security.MessageDigest

/**
 * Manages smart 5-second timeline segment pre-render caching and Android Thermal API throttling.
 * Part of Video365 "Render on the Go" pipeline.
 */
class SegmentPreRenderCache(private val context: Context) {
    private val segmentDurationMs = 5000L
    private var thermalDownsample = 1.0f // 1.0f = full res, 0.5f = 1/2, 0.25f = 1/4

    init {
        setupThermalMonitoring()
    }

    private fun setupThermalMonitoring() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            powerManager?.addThermalStatusListener { status ->
                thermalDownsample = when (status) {
                    PowerManager.THERMAL_STATUS_NONE, PowerManager.THERMAL_STATUS_LIGHT -> 1.0f
                    PowerManager.THERMAL_STATUS_MODERATE -> 0.5f
                    PowerManager.THERMAL_STATUS_SEVERE, PowerManager.THERMAL_STATUS_CRITICAL -> 0.25f
                    else -> 0.25f
                }
                Log.i("ThermalCache", "Thermal status changed: $status -> Viewport downsample: $thermalDownsample")
            }
        }
    }

    fun getViewportDownsample(): Float = thermalDownsample

    /**
     * Evaluates and builds render cache segments for a composition.
     */
    fun evaluateSegments(composition: Composition): List<RenderCacheSegment> {
        val duration = composition.durationMs
        val segmentCount = ((duration + segmentDurationMs - 1) / segmentDurationMs).coerceAtLeast(1)
        val segments = mutableListOf<RenderCacheSegment>()

        for (i in 0 until segmentCount) {
            val startMs = i * segmentDurationMs
            val endMs = (startMs + segmentDurationMs).coerceAtMost(duration)
            val segmentId = "seg_${i}_${startMs}_${endMs}"

            // Compute fast hash of layers intersecting this segment
            val intersectingLayers = composition.layers.filter {
                it.inPointMs < endMs && it.outPointMs > startMs
            }

            val stateString = buildString {
                append("comp:${composition.compId};seg:$startMs-$endMs;")
                for (lyr in intersectingLayers) {
                    append("lyr:${lyr.layerId}:${lyr.type}:${lyr.inPointMs}:${lyr.outPointMs};")
                    append("effects:${lyr.effects.size};transition:${lyr.transitionOut?.transitionId};")
                }
            }

            val hash = sha256(stateString)
            segments.add(
                RenderCacheSegment(
                    segmentId = segmentId,
                    startMs = startMs,
                    endMs = endMs,
                    stateHash = hash,
                    cacheUri = "file://${context.cacheDir}/cache_${segmentId}.mp4",
                    isValid = true
                )
            )
        }

        return segments
    }

    private fun sha256(input: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val bytes = digest.digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }.take(16)
    }
}

