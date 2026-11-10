package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.models.v2.Layer
import com.tharunbirla.librecuts.models.v2.RenderCacheSegment
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel
import kotlin.math.sin

/**
 * Modern Tailwind / Mobile Video Editor Timeline matching attached reference design.
 * Features:
 * - Real-time 60fps moving playhead line with [16s] top pill indicator
 * - Audio waveforms in rounded pills (Blue, Cyan, Orange)
 * - Video filmstrip thumbnails with circular (+) transition split markers
 * - Left rounded track icon pills (Music, Text, Gallery, Camera, Filter)
 * - Horizontal drag to move layer across time
 * - Left (<) and Right (>) trim handles
 * - Undo, Redo, and (+ Add Layer) header controls
 */
@Composable
fun Timeline(
    viewModel: Video365ViewModel,
    layers: List<Layer>,
    currentTimeMs: Long,
    durationMs: Long,
    renderCacheSegments: List<RenderCacheSegment> = emptyList(),
    onSeek: (Long) -> Unit,
    onOpenFontManager: () -> Unit = {},
    onAddLayerClick: () -> Unit = {}
) {
    var zoomLevel by remember { mutableFloatStateOf(0.06f) } // pixels per ms
    val scrollState = rememberScrollState()

    val selectedLayerId by viewModel.selectedLayerId.collectAsState()
    val hiddenLayers by viewModel.hiddenLayerIds.collectAsState()
    val mutedLayers by viewModel.mutedLayerIds.collectAsState()

    val selectedLayer = layers.find { it.layerId == selectedLayerId }
    val effectiveDurationMs = durationMs.coerceAtLeast(15000L)
    val normalizedTimeMs = if (effectiveDurationMs > 0) currentTimeMs % effectiveDurationMs else currentTimeMs

    // Smooth auto-scroll following the playhead
    LaunchedEffect(normalizedTimeMs) {
        val playheadDp = (normalizedTimeMs * zoomLevel).toInt()
        val targetScroll = (playheadDp - 150).coerceAtLeast(0)
        if (kotlin.math.abs(scrollState.value - targetScroll) > 80) {
            scrollState.scrollTo(targetScroll)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0B0F19))
    ) {
        // ── 1. TIMELINE HEADER: Title, Duration & Undo/Redo/Add Layer ──
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp)
                .background(Color(0xFF0F172A))
                .padding(horizontal = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            // Left: "Timeline  4.93s / 15.00s"
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Timeline",
                    color = Color(0xFFF8FAFC),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = String.format("%.2fs / %.2fs", normalizedTimeMs / 1000f, effectiveDurationMs / 1000f),
                    color = Color(0xFF94A3B8),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            // Right: Undo, Redo, and (+ Add Layer)
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                // Undo Button
                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E293B))
                        .clickable { viewModel.undo() },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.Undo(tint = Color(0xFFE2E8F0), size = 16.dp)
                }

                // Redo Button
                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E293B))
                        .clickable { viewModel.redo() },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.Redo(tint = Color(0xFFE2E8F0), size = 16.dp)
                }

                // Add Layer Pill (+)
                Box(
                    modifier = Modifier
                        .height(30.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color(0xFF06B6D4))
                        .clickable { onAddLayerClick() }
                        .padding(horizontal = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        Video365Icons.Add(tint = Color.Black, size = 14.dp)
                        Text(
                            text = "Layer",
                            color = Color.Black,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }

        // ── 2. QUICK EDIT ACTION BAR (when a layer is selected) ────────
        if (selectedLayer != null) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(36.dp)
                    .background(Color(0xFF131C31))
                    .padding(horizontal = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = selectedLayer.textData?.text?.take(16) ?: selectedLayer.layerId.take(14),
                    color = Color(0xFF06B6D4),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.width(100.dp)
                )

                Row(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
                    // Split at playhead
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFF06B6D4).copy(alpha = 0.2f))
                            .clickable { viewModel.splitLayerAtPlayhead(selectedLayer.layerId) }
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text("Split", color = Color(0xFF06B6D4), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                    }

                    // Font / Edit Text (for text layers)
                    if (selectedLayer.type == "TEXT" || selectedLayer.textData != null) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(Color(0xFF8B5CF6).copy(alpha = 0.25f))
                                .clickable { onOpenFontManager() }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text("Font", color = Color(0xFFC4B5FD), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    // Duplicate
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFF1E293B))
                            .clickable { viewModel.duplicateLayer(selectedLayer.layerId) }
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text("Copy", color = Color(0xFF94A3B8), fontSize = 10.sp)
                    }

                    // Delete
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFFEF4444).copy(alpha = 0.2f))
                            .clickable { viewModel.deleteLayer(selectedLayer.layerId) }
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text("Del", color = Color(0xFFF87171), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        // ── 3. MAIN MULTI-TRACK TIMELINE CONTAINER ─────────────────────
        Row(modifier = Modifier.fillMaxWidth().weight(1f)) {

            // LEFT COLUMN: Rounded Track Icon Badges (Music, Text, Gallery, Camera)
            Column(
                modifier = Modifier
                    .width(52.dp)
                    .fillMaxHeight()
                    .background(Color(0xFF0F172A))
                    .padding(vertical = 4.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Header spacer matching ruler height
                Spacer(modifier = Modifier.height(26.dp))

                // Track Icon Pill for each layer
                layers.forEach { layer ->
                    val isSelected = selectedLayerId == layer.layerId
                    val isHidden = hiddenLayers.contains(layer.layerId)

                    Box(
                        modifier = Modifier
                            .padding(vertical = 5.dp)
                            .size(38.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(
                                if (isSelected) Color(0xFF06B6D4).copy(alpha = 0.25f)
                                else Color(0xFF1E293B)
                            )
                            .border(
                                width = if (isSelected) 1.5.dp else 0.dp,
                                color = if (isSelected) Color(0xFF06B6D4) else Color.Transparent,
                                shape = RoundedCornerShape(12.dp)
                            )
                            .clickable { viewModel.selectLayer(layer.layerId) },
                        contentAlignment = Alignment.Center
                    ) {
                        val iconTint = if (isHidden) Color.DarkGray
                        else when (layer.type) {
                            "AUDIO" -> Color(0xFF38BDF8)
                            "TEXT" -> Color(0xFF4ADE80)
                            "SHAPE", "STICKER" -> Color(0xFFFBBF24)
                            "VIDEO" -> Color(0xFFA78BFA)
                            "ADJUSTMENT" -> Color(0xFFF472B6)
                            else -> Color(0xFFE2E8F0)
                        }

                        when (layer.type) {
                            "AUDIO" -> Video365Icons.Music(tint = iconTint, size = 18.dp)
                            "TEXT" -> Video365Icons.Text(tint = iconTint, size = 18.dp)
                            "SHAPE", "STICKER" -> Video365Icons.Gallery(tint = iconTint, size = 18.dp)
                            "VIDEO" -> Video365Icons.Camera(tint = iconTint, size = 18.dp)
                            "ADJUSTMENT" -> Video365Icons.Filter(tint = iconTint, size = 18.dp)
                            else -> Video365Icons.Gallery(tint = iconTint, size = 18.dp)
                        }
                    }
                }
            }

            // RIGHT COLUMN: Horizontally Scrollable Lanes with moving Playhead
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .horizontalScroll(scrollState)
            ) {
                val totalWidthDp = (effectiveDurationMs * zoomLevel).dp.coerceAtLeast(600.dp)

                Column(modifier = Modifier.width(totalWidthDp).fillMaxHeight()) {

                    // ── Time Ruler with Dots and Seconds ──
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(26.dp)
                            .background(Color(0xFF0B0F19))
                            .pointerInput(Unit) {
                                detectDragGestures { change, _ ->
                                    val newMs = (change.position.x / zoomLevel).toLong().coerceIn(0L, effectiveDurationMs)
                                    onSeek(newMs)
                                }
                            }
                            .clickable { /* Tap to seek handled by pointer */ }
                    ) {
                        Canvas(modifier = Modifier.fillMaxSize()) {
                            val w = size.width
                            val totalSec = (effectiveDurationMs / 1000).toInt()
                            for (sec in 0..totalSec) {
                                val x = sec * 1000f * zoomLevel
                                if (x < w) {
                                    val isMajor = sec % 8 == 0
                                    if (isMajor) {
                                        // Tick mark for major intervals
                                        drawLine(
                                            color = Color(0xFF64748B),
                                            start = Offset(x, 4f),
                                            end = Offset(x, 16f),
                                            strokeWidth = 1.5f
                                        )
                                    } else if (sec % 2 == 0) {
                                        // Subtle dot for minor seconds
                                        drawCircle(
                                            color = Color(0xFF334155),
                                            radius = 1.5f,
                                            center = Offset(x, 10f)
                                        )
                                    }
                                }
                            }
                        }

                        // Text labels for 0s, 8s, 16s, 24s...
                        val totalSec = (effectiveDurationMs / 1000).toInt()
                        for (sec in 0..totalSec step 8) {
                            val xOffset = (sec * 1000f * zoomLevel).dp
                            Text(
                                text = "${sec}s",
                                color = Color(0xFF64748B),
                                fontSize = 10.sp,
                                modifier = Modifier
                                    .offset(x = xOffset + 4.dp, y = 2.dp)
                            )
                        }
                    }

                    // ── Track Lanes ──
                    layers.forEach { layer ->
                        TrackRowLane(
                            layer = layer,
                            zoomLevel = zoomLevel,
                            isSelected = selectedLayerId == layer.layerId,
                            onSelect = { viewModel.selectLayer(layer.layerId) },
                            onMove = { deltaMs -> viewModel.moveLayer(layer.layerId, deltaMs) },
                            onTrimStart = { newIn -> viewModel.trimLayerStart(layer.layerId, newIn) },
                            onTrimEnd = { newOut -> viewModel.trimLayerEnd(layer.layerId, newOut) }
                        )
                    }
                }

                // ── PLAYHEAD LINE: Advances smoothly with video playback ──
                val playheadOffsetDp = (normalizedTimeMs * zoomLevel).dp
                val currentSeconds = normalizedTimeMs / 1000f

                Box(
                    modifier = Modifier
                        .offset(x = playheadOffsetDp)
                        .width(2.5.dp)
                        .fillMaxHeight()
                        .background(Color.White)
                ) {
                    // Top Timecode Pill: [ 16s ] matching reference image!
                    Box(
                        modifier = Modifier
                            .align(Alignment.TopCenter)
                            .offset(y = 2.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color.White)
                            .border(width = 1.dp, color = Color(0xFF0F172A), shape = RoundedCornerShape(8.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = String.format("%.1fs", currentSeconds),
                            color = Color(0xFF0F172A),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                }
            }
        }
    }
}

/**
 * Modern rounded track lane representing Audio, Video, Text, or Shape clips.
 */
@Composable
private fun TrackRowLane(
    layer: Layer,
    zoomLevel: Float,
    isSelected: Boolean,
    onSelect: () -> Unit,
    onMove: (Long) -> Unit,
    onTrimStart: (Long) -> Unit,
    onTrimEnd: (Long) -> Unit
) {
    val clipWidthDp = ((layer.outPointMs - layer.inPointMs) * zoomLevel).dp.coerceAtLeast(80.dp)
    val clipOffsetDp = (layer.inPointMs * zoomLevel).dp

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(48.dp)
            .padding(vertical = 4.dp)
    ) {
        // The Interactive Clip Bar
        Box(
            modifier = Modifier
                .offset(x = clipOffsetDp)
                .width(clipWidthDp)
                .fillMaxHeight()
                .clip(RoundedCornerShape(10.dp))
                .background(
                    when (layer.type) {
                        "AUDIO" -> Brush.horizontalGradient(listOf(Color(0xFF1D4ED8), Color(0xFF2563EB)))
                        "TEXT" -> Brush.horizontalGradient(listOf(Color(0xFF065F46), Color(0xFF059669)))
                        "SHAPE", "STICKER" -> Brush.horizontalGradient(listOf(Color(0xFF0E7490), Color(0xFF0891B2)))
                        "VIDEO" -> Brush.horizontalGradient(listOf(Color(0xFF1E293B), Color(0xFF334155)))
                        "ADJUSTMENT" -> Brush.horizontalGradient(listOf(Color(0xFFB45309), Color(0xFFD97706)))
                        else -> Brush.horizontalGradient(listOf(Color(0xFF334155), Color(0xFF475569)))
                    }
                )
                .border(
                    width = if (isSelected) 2.dp else 1.dp,
                    color = if (isSelected) Color(0xFF06B6D4) else Color(0xFF334155),
                    shape = RoundedCornerShape(10.dp)
                )
                .clickable { onSelect() }
                .pointerInput(layer.layerId) {
                    detectDragGestures { change, dragAmount ->
                        change.consume()
                        val deltaMs = (dragAmount.x / zoomLevel).toLong()
                        if (deltaMs != 0L) {
                            onMove(deltaMs)
                        }
                    }
                }
        ) {
            // Visual content inside the clip
            when (layer.type) {
                "AUDIO" -> {
                    // Audio Waveforms
                    Canvas(modifier = Modifier.fillMaxSize().padding(horizontal = 6.dp)) {
                        val canvasW = size.width
                        val canvasH = size.height
                        val barW = 2.5f
                        val gap = 2f
                        val count = (canvasW / (barW + gap)).toInt()
                        for (i in 0 until count) {
                            val x = i * (barW + gap)
                            val peak = ((sin(i * 0.35) * 0.45 + sin(i * 1.5) * 0.35 + 0.5).coerceIn(0.15, 0.95) * canvasH).toFloat()
                            drawLine(
                                color = Color.White.copy(alpha = 0.5f),
                                start = Offset(x, (canvasH - peak) / 2f),
                                end = Offset(x, (canvasH + peak) / 2f),
                                strokeWidth = barW
                            )
                        }
                    }
                }
                "VIDEO" -> {
                    // Video Filmstrip with (+) transition markers
                    Row(
                        modifier = Modifier.fillMaxSize(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        val numFrames = 5
                        repeat(numFrames) { idx ->
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .border(width = 0.5.dp, color = Color.Black.copy(alpha = 0.4f))
                                    .background(Color(0xFF1E293B).copy(alpha = 0.7f + (idx % 2) * 0.15f)),
                                contentAlignment = Alignment.Center
                            ) {
                                // Transition split (+) button between frames
                                if (idx > 0 && idx < numFrames) {
                                    Box(
                                        modifier = Modifier
                                            .size(16.dp)
                                            .clip(CircleShape)
                                            .background(Color.White.copy(alpha = 0.9f)),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text("+", color = Color.Black, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Clip Title
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = layer.textData?.text ?: "${layer.type}: ${layer.layerId.take(12)}",
                    color = Color.White,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            // Selection Trim Handles (< and >)
            if (isSelected) {
                // Left Trim Handle
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .width(16.dp)
                        .fillMaxHeight()
                        .background(Color(0xFF06B6D4))
                        .pointerInput(layer.layerId) {
                            detectDragGestures { change, dragAmount ->
                                change.consume()
                                val deltaMs = (dragAmount.x / zoomLevel).toLong()
                                onTrimStart(layer.inPointMs + deltaMs)
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Text("<", color = Color.Black, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
                }

                // Right Trim Handle
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .width(16.dp)
                        .fillMaxHeight()
                        .background(Color(0xFF06B6D4))
                        .pointerInput(layer.layerId) {
                            detectDragGestures { change, dragAmount ->
                                change.consume()
                                val deltaMs = (dragAmount.x / zoomLevel).toLong()
                                onTrimEnd(layer.outPointMs + deltaMs)
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Text(">", color = Color.Black, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
                }
            }
        }
    }
}
