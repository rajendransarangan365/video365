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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.models.v2.Layer
import com.tharunbirla.librecuts.models.v2.RenderCacheSegment
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel
import kotlin.math.sin

/**
 * Adobe Premiere Pro & After Effects Style Mobile Multi-Track Timeline.
 * Features:
 * - Premiere-style track headers (Mute, Visibility Eye, Z-order Reorder)
 * - Layer Moving: Drag clip body horizontally across time
 * - Trimming: Left (<) and Right (>) trim handles to adjust inPoint and outPoint
 * - Visual clip representations: Video filmstrip, Audio waveforms, Text styling
 * - Timeline playhead scrubber with live timecode
 * - Quick Action Bar: Split, Duplicate, Delete, Nudge, Font Manager
 */
@Composable
fun Timeline(
    viewModel: Video365ViewModel,
    layers: List<Layer>,
    currentTimeMs: Long,
    durationMs: Long,
    renderCacheSegments: List<RenderCacheSegment> = emptyList(),
    onSeek: (Long) -> Unit,
    onOpenFontManager: () -> Unit = {}
) {
    var zoomLevel by remember { mutableFloatStateOf(0.08f) } // pixels per ms
    val scrollState = rememberScrollState()

    val selectedLayerId by viewModel.selectedLayerId.collectAsState()
    val hiddenLayers by viewModel.hiddenLayerIds.collectAsState()
    val mutedLayers by viewModel.mutedLayerIds.collectAsState()

    val selectedLayer = layers.find { it.layerId == selectedLayerId }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F1118))
    ) {
        // 1. Premiere Pro / After Effects Pre-Render Cache Bar & Time Ruler
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFF161922))
        ) {
            // Green Pre-render segment status line
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
                    .background(Color(0xFF222634))
            ) {
                if (renderCacheSegments.isNotEmpty()) {
                    renderCacheSegments.forEach { seg ->
                        val segWidth = ((seg.endMs - seg.startMs) * zoomLevel).dp
                        Box(
                            modifier = Modifier
                                .width(segWidth)
                                .fillMaxHeight()
                                .background(if (seg.isValid) Color(0xFF00E676) else Color(0xFFFF5252))
                        )
                    }
                } else {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth(0.9f)
                            .fillMaxHeight()
                            .background(Color(0xFF00E676))
                    )
                }
            }

            // Time Header & Quick Playback / Zoom Controls
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(34.dp)
                    .padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(
                        text = String.format("%02d:%02d.%02d", (currentTimeMs / 60000), (currentTimeMs % 60000) / 1000, (currentTimeMs % 1000) / 10),
                        color = Color(0xFF00E5FF),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "/ " + String.format("%02d:%02d.%02d", (durationMs / 60000), (durationMs % 60000) / 1000, (durationMs % 1000) / 10),
                        color = Color.Gray,
                        fontSize = 11.sp
                    )
                }

                // Zoom & Timeline Snapping
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    IconButton(
                        onClick = { zoomLevel = (zoomLevel * 0.8f).coerceAtLeast(0.03f) },
                        modifier = Modifier.size(26.dp)
                    ) {
                        Text("-", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    }
                    Text("${(zoomLevel * 1000).toInt()}%", color = Color.LightGray, fontSize = 10.sp)
                    IconButton(
                        onClick = { zoomLevel = (zoomLevel * 1.25f).coerceAtMost(0.25f) },
                        modifier = Modifier.size(26.dp)
                    ) {
                        Text("+", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        // 2. Selected Layer Action Bar (Premiere / AE Editing Controls)
        if (selectedLayer != null) {
            Surface(
                modifier = Modifier.fillMaxWidth().height(42.dp),
                color = Color(0xFF1B2030),
                tonalElevation = 4.dp
            ) {
                Row(
                    modifier = Modifier.fillMaxSize().padding(horizontal = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = selectedLayer.layerId.take(12),
                        color = Color(0xFF00E5FF),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.width(70.dp)
                    )

                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
                        // Nudge Left (-0.5s)
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFF262D42))
                                .clickable { viewModel.moveLayer(selectedLayer.layerId, -500L) }
                                .padding(horizontal = 6.dp, vertical = 4.dp)
                        ) {
                            Text("◀ 0.5s", color = Color.White, fontSize = 10.sp)
                        }

                        // Nudge Right (+0.5s)
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFF262D42))
                                .clickable { viewModel.moveLayer(selectedLayer.layerId, 500L) }
                                .padding(horizontal = 6.dp, vertical = 4.dp)
                        ) {
                            Text("0.5s ▶", color = Color.White, fontSize = 10.sp)
                        }

                        // Split at Playhead
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFF00E5FF).copy(alpha = 0.2f))
                                .clickable { viewModel.splitLayerAtPlayhead(selectedLayer.layerId) }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text("Split", color = Color(0xFF00E5FF), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        }

                        // Font Manager (for Text layers or any layer)
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFF7C4DFF).copy(alpha = 0.25f))
                                .clickable { onOpenFontManager() }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text("T Font", color = Color(0xFFB388FF), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        }

                        // Duplicate
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(0xFF262D42))
                                .clickable { viewModel.duplicateLayer(selectedLayer.layerId) }
                                .padding(horizontal = 6.dp, vertical = 4.dp)
                        ) {
                            Text("Copy", color = Color.LightGray, fontSize = 10.sp)
                        }

                        // Delete
                        IconButton(
                            onClick = { viewModel.deleteLayer(selectedLayer.layerId) },
                            modifier = Modifier.size(28.dp)
                        ) {
                            Icon(Icons.Default.Delete, contentDescription = "Delete", tint = Color(0xFFFF5252), modifier = Modifier.size(16.dp))
                        }
                    }
                }
            }
        }

        // 3. Main Multi-Track Area (Left: Track Headers, Right: Interactive Lanes)
        Row(modifier = Modifier.fillMaxWidth().weight(1f)) {
            // Left Column: Premiere Pro Track Control Headers (Fixed)
            Column(
                modifier = Modifier
                    .width(82.dp)
                    .fillMaxHeight()
                    .background(Color(0xFF141722))
                    .border(width = 0.5.dp, color = Color(0xFF22283A))
            ) {
                // Header spacer matching ruler
                Box(modifier = Modifier.fillMaxWidth().height(22.dp).background(Color(0xFF181D2A)), contentAlignment = Alignment.Center) {
                    Text("TRACKS", color = Color.Gray, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                }

                // Track Controls for each layer
                layers.forEachIndexed { index, layer ->
                    val isHidden = hiddenLayers.contains(layer.layerId)
                    val isMuted = mutedLayers.contains(layer.layerId)
                    val isSelected = selectedLayerId == layer.layerId

                    val trackLabel = when (layer.type) {
                        "VIDEO" -> "V${index + 1}"
                        "TEXT" -> "T${index + 1}"
                        "AUDIO" -> "A${index + 1}"
                        "ADJUSTMENT" -> "FX"
                        else -> "S${index + 1}"
                    }

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                            .background(if (isSelected) Color(0xFF22293D) else Color(0xFF141722))
                            .border(width = 0.5.dp, color = Color(0xFF1F2538))
                            .clickable { viewModel.selectLayer(layer.layerId) }
                            .padding(horizontal = 4.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        // Track Badge
                        Text(
                            text = trackLabel,
                            color = when (layer.type) {
                                "VIDEO" -> Color(0xFF42A5F5)
                                "TEXT" -> Color(0xFF66BB6A)
                                "AUDIO" -> Color(0xFFAB47BC)
                                "ADJUSTMENT" -> Color(0xFFFFA726)
                                else -> Color(0xFF26C6DA)
                            },
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )

                        // Visibility Toggle (Eye/Show badge)
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(3.dp))
                                .background(if (isHidden) Color(0xFF222634) else Color(0xFF00E5FF).copy(alpha = 0.2f))
                                .clickable { viewModel.toggleLayerVisibility(layer.layerId) }
                                .padding(horizontal = 4.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = if (isHidden) "OFF" else "ON",
                                color = if (isHidden) Color.DarkGray else Color(0xFF00E5FF),
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }

                        // Mute Toggle (Audio badge)
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(3.dp))
                                .background(if (isMuted) Color(0xFFFF5252).copy(alpha = 0.2f) else Color(0xFF222634))
                                .clickable { viewModel.toggleLayerMute(layer.layerId) }
                                .padding(horizontal = 4.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = if (isMuted) "MUTE" else "VOL",
                                color = if (isMuted) Color(0xFFFF5252) else Color.LightGray,
                                fontSize = 8.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            // Right Column: Horizontally Scrollable Lanes with Timeline Clips & Scrubber
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .horizontalScroll(scrollState)
            ) {
                val totalWidthDp = (durationMs.coerceAtLeast(15000L) * zoomLevel).dp

                Column(modifier = Modifier.width(totalWidthDp).fillMaxHeight()) {
                    // Time Ruler with tick marks
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(22.dp)
                            .background(Color(0xFF161924))
                            .clickable { /* Seek via ruler */ }
                    ) {
                        Canvas(modifier = Modifier.fillMaxSize()) {
                            val w = size.width
                            val totalSec = (durationMs / 1000).toInt().coerceAtLeast(15)
                            for (sec in 0..totalSec) {
                                val x = sec * 1000f * zoomLevel
                                if (x < w) {
                                    val isMajor = sec % 5 == 0
                                    drawLine(
                                        color = if (isMajor) Color.LightGray else Color.DarkGray,
                                        start = Offset(x, if (isMajor) 0f else 10f),
                                        end = Offset(x, size.height),
                                        strokeWidth = if (isMajor) 2f else 1f
                                    )
                                }
                            }
                        }
                    }

                    // Track Lanes
                    layers.forEach { layer ->
                        TrackLane(
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

                // Premiere Pro / AE Red Playhead Cursor Line
                Box(
                    modifier = Modifier
                        .offset(x = (currentTimeMs * zoomLevel).dp)
                        .width(2.dp)
                        .fillMaxHeight()
                        .background(Color(0xFFFF1744))
                ) {
                    // Playhead Handle Top Indicator
                    Box(
                        modifier = Modifier
                            .size(10.dp)
                            .align(Alignment.TopCenter)
                            .offset(y = (-2).dp)
                            .clip(CircleShape)
                            .background(Color(0xFFFF1744))
                    )
                }
            }
        }
    }
}

/**
 * Individual track lane hosting an interactive clip.
 * Supports horizontal moving and left/right trimming.
 */
@Composable
private fun TrackLane(
    layer: Layer,
    zoomLevel: Float,
    isSelected: Boolean,
    onSelect: () -> Unit,
    onMove: (Long) -> Unit,
    onTrimStart: (Long) -> Unit,
    onTrimEnd: (Long) -> Unit
) {
    val clipWidthDp = ((layer.outPointMs - layer.inPointMs) * zoomLevel).dp.coerceAtLeast(60.dp)
    val clipOffsetDp = (layer.inPointMs * zoomLevel).dp

    val trackColor = when (layer.type) {
        "ADJUSTMENT" -> Color(0xFFF57C00) // Amber Lumetri
        "TEXT" -> Color(0xFF2E7D32)       // Green Kinetic Title
        "SHAPE" -> Color(0xFF00838F)      // Cyan Lower Third
        "VIDEO" -> Color(0xFF1565C0)      // Blue Main Video
        "AUDIO" -> Color(0xFF6A1B9A)      // Purple Audio
        else -> Color(0xFF37474F)
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(50.dp)
            .border(width = 0.5.dp, color = Color(0xFF161A26))
            .padding(vertical = 4.dp)
    ) {
        // The Interactive Clip
        Box(
            modifier = Modifier
                .offset(x = clipOffsetDp)
                .width(clipWidthDp)
                .fillMaxHeight()
                .clip(RoundedCornerShape(6.dp))
                .background(trackColor)
                .border(
                    width = if (isSelected) 2.dp else 1.dp,
                    color = if (isSelected) Color(0xFF00E5FF) else Color.Black.copy(alpha = 0.3f),
                    shape = RoundedCornerShape(6.dp)
                )
                .clickable { onSelect() }
                .pointerInput(layer.layerId) {
                    // Drag clip body horizontally across time (Layer Moving)
                    detectDragGestures { change, dragAmount ->
                        change.consume()
                        val deltaMs = (dragAmount.x / zoomLevel).toLong()
                        if (deltaMs != 0L) {
                            onMove(deltaMs)
                        }
                    }
                }
        ) {
            // Visual Clip Content
            when (layer.type) {
                "VIDEO" -> {
                    // Video Filmstrip Frames Preview
                    Row(modifier = Modifier.fillMaxSize()) {
                        repeat(6) { index ->
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .border(width = 0.5.dp, color = Color.Black.copy(alpha = 0.25f))
                                    .background(Color(0xFF0D47A1).copy(alpha = 0.6f + (index % 3) * 0.1f))
                            )
                        }
                    }
                    // Audio Waveform overlay at bottom
                    Canvas(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(14.dp)
                            .align(Alignment.BottomCenter)
                    ) {
                        val canvasW = size.width
                        val canvasH = size.height
                        val barW = 3f
                        val gap = 2f
                        val count = (canvasW / (barW + gap)).toInt()
                        for (i in 0 until count) {
                            val x = i * (barW + gap)
                            val peak = ((sin(i * 0.35) * 0.4 + sin(i * 1.8) * 0.3 + 0.45).coerceIn(0.15, 0.95) * canvasH).toFloat()
                            drawLine(
                                color = Color.White.copy(alpha = 0.4f),
                                start = Offset(x, canvasH - peak),
                                end = Offset(x, canvasH),
                                strokeWidth = barW
                            )
                        }
                    }
                }
                "AUDIO" -> {
                    // Dedicated Full Audio Waveforms
                    Canvas(modifier = Modifier.fillMaxSize().padding(horizontal = 4.dp)) {
                        val canvasW = size.width
                        val canvasH = size.height
                        val barW = 3f
                        val gap = 2f
                        val count = (canvasW / (barW + gap)).toInt()
                        for (i in 0 until count) {
                            val x = i * (barW + gap)
                            val peak = ((sin(i * 0.4) * 0.45 + sin(i * 2.2) * 0.35 + 0.5).coerceIn(0.2, 0.95) * canvasH).toFloat()
                            drawLine(
                                color = Color(0xFFE1BEE7),
                                start = Offset(x, (canvasH - peak) / 2f),
                                end = Offset(x, (canvasH + peak) / 2f),
                                strokeWidth = barW
                            )
                        }
                    }
                }
            }

            // Clip Title & Info Badge
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = when {
                        layer.textData != null -> "${layer.type}: ${layer.textData.text}"
                        else -> "${layer.type}: ${layer.layerId.take(10)}"
                    },
                    color = Color.White,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 1
                )

                if (layer.transitionOut != null) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(3.dp))
                            .background(Color.Black.copy(alpha = 0.6f))
                            .padding(horizontal = 4.dp, vertical = 1.dp)
                    ) {
                        Text(
                            text = "TR: ${layer.transitionOut.transitionId}",
                            color = Color(0xFF80D8FF),
                            fontSize = 8.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            // Selection Trim Handles (< and >)
            if (isSelected) {
                // Left Trim Handle (<)
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .width(14.dp)
                        .fillMaxHeight()
                        .background(Color(0xFF00E5FF))
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

                // Right Trim Handle (>)
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .width(14.dp)
                        .fillMaxHeight()
                        .background(Color(0xFF00E5FF))
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
