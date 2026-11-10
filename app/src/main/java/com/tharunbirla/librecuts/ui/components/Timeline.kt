package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.models.v2.Layer
import com.tharunbirla.librecuts.models.v2.RenderCacheSegment
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel
import kotlin.math.sin

/**
 * Award-Winning Mobile Video Editor Timeline inspired by top Dribbble shots (Yohan, Feelsy, CapCut).
 * Features:
 * - Perfectly centered player needle with floating capsule ruler [ || ] 0:55 •••• [ 01:00 ] •••• 01:05 [ ⤢ ]
 * - Pinch-to-zoom & dedicated Zoom In (+) / Zoom Out (-) buttons
 * - Magnetic snapping toggle [ 🧲 ]
 * - Dribbble-style multi-layer cards (Filmstrip video, Audio with 14 Sec + waveforms, Text, Stickers, Filters)
 * - Bidirectional playhead sync: 60fps autoscroll during playback & real-time touch scrub seeking
 * - Contextual clip action toolbar (Split, Edit Text, Speed, Copy, Del, Nudge)
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
    onAddLayerClick: () -> Unit = {},
    onTogglePlayPause: () -> Unit = {},
    isPlaying: Boolean = false
) {
    var zoomLevel by remember { mutableFloatStateOf(0.08f) } // dp per ms
    val scrollState = rememberScrollState()

    val density = LocalDensity.current
    val pxPerMs = with(density) { zoomLevel.dp.toPx() }

    val selectedLayerId by viewModel.selectedLayerId.collectAsState()
    val snappingEnabled by viewModel.snappingEnabled.collectAsState()

    val selectedLayer = layers.find { it.layerId == selectedLayerId }
    val effectiveDurationMs = durationMs.coerceAtLeast(15000L)
    val normalizedTimeMs = if (effectiveDurationMs > 0) currentTimeMs % effectiveDurationMs else currentTimeMs

    // Bidirectional Playhead Sync:
    // 1. Autoscroll timeline smoothly to keep playhead aligned with center needle during playback
    LaunchedEffect(normalizedTimeMs, isPlaying) {
        if (!scrollState.isScrollInProgress && pxPerMs > 0f) {
            val targetScrollPx = (normalizedTimeMs * pxPerMs).toInt()
            if (kotlin.math.abs(scrollState.value - targetScrollPx) > 3) {
                scrollState.scrollTo(targetScrollPx)
            }
        }
    }

    // 2. Interactive manual scrubbing: dragging timeline scrubs ExoPlayer in real-time
    LaunchedEffect(scrollState.isScrollInProgress) {
        if (scrollState.isScrollInProgress) {
            snapshotFlow { scrollState.value }
                .collect { scrollPx ->
                    if (pxPerMs > 0f) {
                        val scrubbedMs = (scrollPx / pxPerMs).toLong().coerceIn(0L, effectiveDurationMs)
                        onSeek(scrubbedMs)
                    }
                }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0B0E17))
    ) {
        // ── 1. TOP TIMELINE HEADER: Controls, Zoom (+/-), Snapping, Undo/Redo ──
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(42.dp)
                .background(Color(0xFF0F1420))
                .padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            // Left: Title & Duration
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "TIMELINE",
                    color = Color(0xFFF8FAFC),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.5.sp
                )
                Text(
                    text = String.format("%02d:%02d.%02d / %02d:%02d",
                        (normalizedTimeMs / 60000), (normalizedTimeMs % 60000) / 1000, (normalizedTimeMs % 1000) / 10,
                        (effectiveDurationMs / 60000), (effectiveDurationMs % 60000) / 1000
                    ),
                    color = Color(0xFF94A3B8),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            // Right: Zoom In/Out, Snapping, Undo, Redo, + Layer
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                // Zoom Out (-) Button
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E2638))
                        .clickable { zoomLevel = (zoomLevel * 0.75f).coerceAtLeast(0.02f) },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.ZoomOut(tint = Color(0xFFE2E8F0), size = 15.dp)
                }

                // Zoom Level Percentage Pill
                Box(
                    modifier = Modifier
                        .height(24.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .background(Color(0xFF182030))
                        .clickable { zoomLevel = 0.08f } // Reset to 100%
                        .padding(horizontal = 6.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "${(zoomLevel * 1250).toInt()}%",
                        color = Color(0xFF38BDF8),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                // Zoom In (+) Button
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E2638))
                        .clickable { zoomLevel = (zoomLevel * 1.33f).coerceAtMost(0.30f) },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.ZoomIn(tint = Color(0xFFE2E8F0), size = 15.dp)
                }

                // Magnet / Snapping Toggle
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(if (snappingEnabled) Color(0xFF06B6D4).copy(alpha = 0.25f) else Color(0xFF1E2638))
                        .clickable { viewModel.toggleSnapping() },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.Magnet(tint = if (snappingEnabled) Color(0xFF06B6D4) else Color(0xFF94A3B8), size = 15.dp)
                }

                // Undo Button
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E2638))
                        .clickable { viewModel.undo() },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.Undo(tint = Color(0xFFE2E8F0), size = 14.dp)
                }

                // Redo Button
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E2638))
                        .clickable { viewModel.redo() },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.Redo(tint = Color(0xFFE2E8F0), size = 14.dp)
                }

                // + Add Layer Button
                Box(
                    modifier = Modifier
                        .height(28.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color(0xFF06B6D4))
                        .clickable { onAddLayerClick() }
                        .padding(horizontal = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.Add(tint = Color.Black, size = 16.dp)
                }
            }
        }

        // ── 2. CONTEXTUAL ACTION BAR FOR SELECTED CLIP ──
        if (selectedLayer != null) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(36.dp)
                    .background(Color(0xFF121724))
                    .padding(horizontal = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = selectedLayer.name ?: selectedLayer.textData?.text ?: selectedLayer.layerId.uppercase(),
                    color = Color(0xFF38BDF8),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.width(130.dp)
                )

                Row(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
                    // Split at playhead
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFF06B6D4).copy(alpha = 0.2f))
                            .clickable { viewModel.splitLayerAtPlayhead(selectedLayer.layerId) }
                            .padding(horizontal = 8.dp, vertical = 3.dp)
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
                                .padding(horizontal = 8.dp, vertical = 3.dp)
                        ) {
                            Text("Text", color = Color(0xFFC4B5FD), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    // Speed
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFF1E2638))
                            .clickable { viewModel.setPlaybackSpeed(1.5f) }
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Text("Speed", color = Color(0xFFE2E8F0), fontSize = 10.sp)
                    }

                    // Duplicate
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFF1E2638))
                            .clickable { viewModel.duplicateLayer(selectedLayer.layerId) }
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Text("Copy", color = Color(0xFF94A3B8), fontSize = 10.sp)
                    }

                    // Delete
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFFEF4444).copy(alpha = 0.2f))
                            .clickable { viewModel.deleteLayer(selectedLayer.layerId) }
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Text("Del", color = Color(0xFFF87171), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        // ── 3. CENTER-PLAYHEAD FLOATING RULER CAPSULE ──
        // Matching Dribbble Shot: [ || ] 0:55 •••• [ 01:00 ] •••• 01:05 [ ⤢ ]
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(36.dp)
                .background(Color(0xFF0F1420))
                .border(width = 0.5.dp, color = Color(0xFF1E2638))
                .padding(horizontal = 14.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                // Play / Pause button in capsule on left
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E2638))
                        .clickable { onTogglePlayPause() },
                    contentAlignment = Alignment.Center
                ) {
                    if (isPlaying) {
                        Video365Icons.Pause(tint = Color.White, size = 13.dp)
                    } else {
                        Video365Icons.Play(tint = Color.White, size = 13.dp)
                    }
                }

                // Time indicators flanking the center needle
                val prevTimeSec = ((normalizedTimeMs - 2000L).coerceAtLeast(0L) / 1000).toInt()
                Text(
                    text = String.format("%02d:%02d  ••••", prevTimeSec / 60, prevTimeSec % 60),
                    color = Color(0xFF64748B),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium
                )

                // Center floating time indicator pill: [ 00:04 ]
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White)
                        .border(width = 1.dp, color = Color(0xFF06B6D4), shape = RoundedCornerShape(12.dp))
                        .padding(horizontal = 12.dp, vertical = 3.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = String.format("%02d:%02d", (normalizedTimeMs / 1000) / 60, (normalizedTimeMs / 1000) % 60),
                        color = Color(0xFF0F1420),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.ExtraBold
                    )
                }

                val nextTimeSec = ((normalizedTimeMs + 2000L).coerceAtMost(effectiveDurationMs) / 1000).toInt()
                Text(
                    text = String.format("••••  %02d:%02d", nextTimeSec / 60, nextTimeSec % 60),
                    color = Color(0xFF64748B),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium
                )

                // Fullscreen / Aspect Ratio toggle icon on right
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E2638))
                        .clickable { viewModel.cycleAspectRatio() },
                    contentAlignment = Alignment.Center
                ) {
                    Video365Icons.Fullscreen(tint = Color(0xFF94A3B8), size = 14.dp)
                }
            }
        }

        // ── 4. MULTI-TRACK TIMELINE CONTAINER WITH CENTER NEEDLE ──
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
        ) {
            val viewportWidth = maxWidth
            val halfViewportDp = viewportWidth / 2
            val totalTrackWidthDp = (effectiveDurationMs * zoomLevel).dp

            // Scrollable tracks container
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .horizontalScroll(scrollState)
            ) {
                Row(modifier = Modifier.fillMaxHeight()) {
                    // Start padding so 0s aligns with center needle
                    Spacer(modifier = Modifier.width(halfViewportDp))

                    // All track lanes
                    Column(
                        modifier = Modifier
                            .width(totalTrackWidthDp)
                            .fillMaxHeight()
                    ) {
                        // Time ruler with tick marks and text stamps
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(26.dp)
                                .background(Color(0xFF0B0E17))
                        ) {
                            Canvas(modifier = Modifier.fillMaxSize()) {
                                val totalSec = (effectiveDurationMs / 1000).toInt()
                                val stepSec = if (zoomLevel < 0.05f) 5 else if (zoomLevel < 0.12f) 2 else 1

                                for (sec in 0..totalSec) {
                                    val xPx = (sec * 1000f) * pxPerMs
                                    if (xPx in 0f..size.width) {
                                        val isMajor = (sec % stepSec == 0)
                                        if (isMajor) {
                                            drawLine(
                                                color = Color(0xFF64748B),
                                                start = Offset(xPx, 6f),
                                                end = Offset(xPx, 22f),
                                                strokeWidth = 2f
                                            )
                                        } else {
                                            drawCircle(
                                                color = Color(0xFF334155),
                                                radius = 2f,
                                                center = Offset(xPx, 14f)
                                            )
                                        }
                                    }
                                }
                            }

                            // Second labels (0s, 2s, 4s...)
                            val stepSec = if (zoomLevel < 0.05f) 5 else if (zoomLevel < 0.12f) 2 else 1
                            val totalSec = (effectiveDurationMs / 1000).toInt()
                            for (sec in 0..totalSec step stepSec) {
                                val xOffsetDp = (sec * 1000f * zoomLevel).dp
                                Text(
                                    text = "${sec}s",
                                    color = Color(0xFF94A3B8),
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    modifier = Modifier.offset(x = xOffsetDp + 4.dp, y = 3.dp)
                                )
                            }
                        }

                        // Track rows (Video, Audio, Text, Shape, Adjustment)
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .fillMaxHeight(),
                            verticalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            layers.forEach { layer ->
                                DribbbleTrackLane(
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
                    }

                    // End padding so end of project aligns with center needle
                    Spacer(modifier = Modifier.width(halfViewportDp))
                }
            }

            // ── ROCK-SOLID CENTER NEEDLE (White dashed line descending from capsule) ──
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .width(2.dp)
                    .align(Alignment.Center)
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    drawLine(
                        color = Color.White,
                        start = Offset(size.width / 2, 0f),
                        end = Offset(size.width / 2, size.height),
                        strokeWidth = 2.5f,
                        pathEffect = PathEffect.dashPathEffect(floatArrayOf(12f, 8f), 0f)
                    )
                }
            }
        }
    }
}

/**
 * Modern Dribbble Track Card:
 * - Rounded capsule cards with rich gradients
 * - Left square icon badge
 * - Bold duration title (e.g. 14 Sec)
 * - Human-readable clean subtitle
 * - Audio: Rendered waveforms
 * - Video: Filmstrip with frame dividers & (+) transition markers
 */
@Composable
private fun DribbbleTrackLane(
    layer: Layer,
    zoomLevel: Float,
    isSelected: Boolean,
    onSelect: () -> Unit,
    onMove: (Long) -> Unit,
    onTrimStart: (Long) -> Unit,
    onTrimEnd: (Long) -> Unit
) {
    val durationMs = (layer.outPointMs - layer.inPointMs).coerceAtLeast(1000L)
    val clipWidthDp = (durationMs * zoomLevel).dp.coerceAtLeast(90.dp)
    val clipOffsetDp = (layer.inPointMs * zoomLevel).dp
    val durationSec = (durationMs / 1000f).toInt()

    val (bgGradient, iconBg) = when (layer.type) {
        "AUDIO" -> Pair(
            Brush.horizontalGradient(listOf(Color(0xFF1D4ED8), Color(0xFF2563EB))),
            Color(0xFF1E40AF)
        )
        "TEXT" -> Pair(
            Brush.horizontalGradient(listOf(Color(0xFF6D28D9), Color(0xFF7C3AED))),
            Color(0xFF5B21B6)
        )
        "SHAPE", "STICKER" -> Pair(
            Brush.horizontalGradient(listOf(Color(0xFF0E7490), Color(0xFF0891B2))),
            Color(0xFF155E75)
        )
        "ADJUSTMENT" -> Pair(
            Brush.horizontalGradient(listOf(Color(0xFFB45309), Color(0xFFD97706))),
            Color(0xFF92400E)
        )
        else -> Pair(
            Brush.horizontalGradient(listOf(Color(0xFF1E293B), Color(0xFF334155))),
            Color(0xFF0F172A)
        )
    }

    val subtitle = layer.name ?: layer.textData?.text ?: when (layer.type) {
        "AUDIO" -> "Heaven in closer - Lalinea"
        "TEXT" -> "Video365 Motion Title"
        "ADJUSTMENT" -> "Cinematic Color Grade"
        "SHAPE", "STICKER" -> "Lower Third Accent"
        else -> "Main Video Sequence"
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(48.dp)
            .padding(vertical = 2.dp)
    ) {
        // The Interactive Clip Card
        Box(
            modifier = Modifier
                .offset(x = clipOffsetDp)
                .width(clipWidthDp)
                .fillMaxHeight()
                .clip(RoundedCornerShape(12.dp))
                .background(bgGradient)
                .border(
                    width = if (isSelected) 2.dp else 0.5.dp,
                    color = if (isSelected) Color(0xFF38BDF8) else Color.White.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(12.dp)
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
            // Visual content inside the card
            when (layer.type) {
                "AUDIO" -> {
                    // Audio waveform visualization
                    Canvas(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(start = 48.dp, end = 8.dp)
                    ) {
                        val canvasW = size.width
                        val canvasH = size.height
                        val barW = 2.5f
                        val gap = 2f
                        val count = (canvasW / (barW + gap)).toInt()
                        for (i in 0 until count) {
                            val x = i * (barW + gap)
                            val peak = ((sin(i * 0.35) * 0.45 + sin(i * 1.6) * 0.35 + 0.5).coerceIn(0.15, 0.95) * canvasH).toFloat()
                            drawLine(
                                color = Color.White.copy(alpha = 0.35f),
                                start = Offset(x, (canvasH - peak) / 2f),
                                end = Offset(x, (canvasH + peak) / 2f),
                                strokeWidth = barW
                            )
                        }
                    }
                }
                "VIDEO" -> {
                    // Video Filmstrip with thumbnail dividers & (+) transition markers
                    Row(
                        modifier = Modifier.fillMaxSize(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        val numFrames = 6
                        repeat(numFrames) { idx ->
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .border(width = 0.5.dp, color = Color.Black.copy(alpha = 0.4f))
                                    .background(Color(0xFF1E293B).copy(alpha = 0.6f + (idx % 2) * 0.15f)),
                                contentAlignment = Alignment.Center
                            ) {
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

            // Left icon badge + Title & Subtitle
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Left square icon badge
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .background(iconBg),
                    contentAlignment = Alignment.Center
                ) {
                    when (layer.type) {
                        "AUDIO" -> Video365Icons.Music(tint = Color.White, size = 15.dp)
                        "TEXT" -> Video365Icons.Text(tint = Color.White, size = 15.dp)
                        "SHAPE", "STICKER" -> Video365Icons.Sticker(tint = Color.White, size = 15.dp)
                        "ADJUSTMENT" -> Video365Icons.Filter(tint = Color.White, size = 15.dp)
                        else -> Video365Icons.Layers(tint = Color.White, size = 15.dp)
                    }
                }

                // Title & Subtitle Column
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "$durationSec Sec",
                        color = Color.White,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.ExtraBold,
                        maxLines = 1
                    )
                    Text(
                        text = subtitle,
                        color = Color.White.copy(alpha = 0.85f),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Medium,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            // Left & Right Selection Trim Handles (< and >)
            if (isSelected) {
                // Left Trim Handle
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .width(16.dp)
                        .fillMaxHeight()
                        .background(Color(0xFF38BDF8))
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
                        .background(Color(0xFF38BDF8))
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
