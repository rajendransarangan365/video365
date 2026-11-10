package com.tharunbirla.librecuts.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout
import com.google.android.exoplayer2.ui.StyledPlayerView
import com.tharunbirla.librecuts.ui.components.CommandBar
import com.tharunbirla.librecuts.ui.components.EffectsAndTransitionsSheet
import com.tharunbirla.librecuts.ui.components.FontManagerSheet
import com.tharunbirla.librecuts.ui.components.GraphEditor
import com.tharunbirla.librecuts.ui.components.MotionGraphicsViewportOverlay
import com.tharunbirla.librecuts.ui.components.ScriptingConsoleSheet
import com.tharunbirla.librecuts.ui.components.Timeline
import com.tharunbirla.librecuts.ui.components.Video365Icons
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel

/**
 * Professional Video365 Tailwind & Modern Mobile Workspace.
 * Exactly matches the attached design:
 * - Top Bar: Back, "Untitle Project", Checkmark
 * - Video Viewport: Floating frosted glass bar with Mute, Play/Pause, Fullscreen
 * - Timeline: Real-time 60fps playhead tracking, waveforms, filmstrip thumbnails
 * - Bottom Bar: Text, Music, Stickers, Split, Filter
 * - Add Layer Modal & Export Modal with Resolution/FPS sliders
 */
@Composable
fun EditorScreen(
    viewModel: Video365ViewModel,
    player: ExoPlayer? = null
) {
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp > 600

    val project by viewModel.project.collectAsState()
    val currentTimeMs by viewModel.currentTimeMs.collectAsState()
    val isPlaying by viewModel.isPlaying.collectAsState()
    val isMuted by viewModel.isMuted.collectAsState()

    var showCommandBar by remember { mutableStateOf(false) }
    var showEffectsSheet by remember { mutableStateOf(false) }
    var showHowToUse by remember { mutableStateOf(false) }
    var showScriptingConsole by remember { mutableStateOf(false) }
    var showFontManager by remember { mutableStateOf(false) }
    var showAddLayerSheet by remember { mutableStateOf(false) }
    var showExportSheet by remember { mutableStateOf(false) }

    val activePlayer = player ?: viewModel.player

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = Color(0xFF0B0F19)
    ) {
        Column(modifier = Modifier.fillMaxSize().background(Color(0xFF0B0F19))) {

            // ── TOP BAR: Back, "Untitle Project", Checkmark ───────────
            EditorTopBar(
                title = project?.projectMeta?.projectId?.replace("proj_", "")?.let { "Untitle Project" } ?: "Untitle Project",
                onBack = { /* Handle back or navigate */ },
                onExport = { showExportSheet = true }
            )

            // ── VIDEO VIEWPORT: Rounded Player with Floating Glass Bar ─
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1.35f)
                    .padding(horizontal = 16.dp, vertical = 6.dp)
            ) {
                VideoPlayerViewportCard(
                    viewModel = viewModel,
                    project = project,
                    currentTimeMs = currentTimeMs,
                    player = activePlayer,
                    isPlaying = isPlaying,
                    isMuted = isMuted,
                    onTogglePlayPause = { viewModel.togglePlayPause() },
                    onToggleMute = { viewModel.toggleMute() }
                )
            }

            // ── TIMELINE: Real-time 60fps moving playhead, waveforms ──
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1.25f)
            ) {
                Timeline(
                    viewModel = viewModel,
                    layers = project?.compositions?.firstOrNull()?.layers ?: emptyList(),
                    currentTimeMs = currentTimeMs,
                    durationMs = project?.compositions?.firstOrNull()?.durationMs ?: 0L,
                    renderCacheSegments = project?.compositions?.firstOrNull()?.renderCacheSegments ?: emptyList(),
                    onSeek = { viewModel.seekTo(it) },
                    onOpenFontManager = { showFontManager = true },
                    onAddLayerClick = { showAddLayerSheet = true }
                )
            }

            // ── BOTTOM TOOLBAR: Text, Music, Stickers, Split, Filter ──
            EditorTailwindBottomBar(
                onTextClick = { showFontManager = true },
                onMusicClick = { viewModel.addExtraLayer("AUDIO", "Heaven in closer - Lalinea") },
                onStickersClick = { viewModel.addExtraLayer("SHAPE", "Sticker Badge") },
                onSplitClick = { viewModel.splitLayerAtPlayhead() },
                onFilterClick = { showEffectsSheet = true },
                onCommandsClick = { showCommandBar = true }
            )
        }

        // ── DIALOGS & BOTTOM SHEETS ──────────────────────────────────
        if (showAddLayerSheet) {
            AddLayerBottomSheet(
                onDismiss = { showAddLayerSheet = false },
                onSelectType = { type ->
                    showAddLayerSheet = false
                    viewModel.addExtraLayer(type)
                    if (type == "TEXT") {
                        showFontManager = true
                    }
                }
            )
        }

        if (showExportSheet) {
            ExportModalSheet(
                onDismiss = { showExportSheet = false },
                onDownload = {
                    showExportSheet = false
                    // Start export
                }
            )
        }

        if (showCommandBar) {
            CommandBar(
                onDismiss = { showCommandBar = false },
                onOpenScripting = {
                    showCommandBar = false
                    showScriptingConsole = true
                },
                onOpenFontManager = {
                    showCommandBar = false
                    showFontManager = true
                }
            )
        }

        if (showEffectsSheet) {
            EffectsAndTransitionsSheet(
                viewModel = viewModel,
                onDismiss = { showEffectsSheet = false }
            )
        }

        if (showScriptingConsole) {
            ScriptingConsoleSheet(
                viewModel = viewModel,
                onDismiss = { showScriptingConsole = false }
            )
        }

        if (showFontManager) {
            FontManagerSheet(
                viewModel = viewModel,
                onDismiss = { showFontManager = false }
            )
        }

        if (showHowToUse) {
            HowToUseDialog(
                onDismiss = { showHowToUse = false },
                onLaunchDemoProject = {
                    showHowToUse = false
                    viewModel.loadSampleProject()
                }
            )
        }
    }
}

/**
 * Top Editor Navigation Bar matching reference design:
 * Left: Back Arrow (<-)
 * Center: "Untitle Project"
 * Right: Checkmark (✓)
 */
@Composable
private fun EditorTopBar(
    title: String,
    onBack: () -> Unit,
    onExport: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(52.dp)
            .background(Color(0xFF0B0F19))
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        // Back Button
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .clickable { onBack() },
            contentAlignment = Alignment.Center
        ) {
            Video365Icons.Back(tint = Color(0xFFF8FAFC), size = 20.dp)
        }

        // Title
        Text(
            text = title,
            color = Color(0xFFF8FAFC),
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold
        )

        // Checkmark (Done / Export)
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .clickable { onExport() },
            contentAlignment = Alignment.Center
        ) {
            Video365Icons.Check(tint = Color(0xFFF8FAFC), size = 20.dp)
        }
    }
}

/**
 * Video Player Viewport Card:
 * - Rounded container with border
 * - Floating frosted glass bar at bottom with Mute, Play/Pause, Fullscreen
 */
@Composable
private fun VideoPlayerViewportCard(
    viewModel: Video365ViewModel,
    project: com.tharunbirla.librecuts.models.v2.Video365Project?,
    currentTimeMs: Long,
    player: ExoPlayer?,
    isPlaying: Boolean,
    isMuted: Boolean,
    onTogglePlayPause: () -> Unit,
    onToggleMute: () -> Unit
) {
    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .clip(RoundedCornerShape(20.dp))
            .background(Color(0xFF070A11))
            .border(width = 1.dp, color = Color(0xFF1E293B), shape = RoundedCornerShape(20.dp)),
        contentAlignment = Alignment.Center
    ) {
        val ratioFloat = when (project?.projectMeta?.orientation) {
            "HORIZONTAL_16_9", "16:9" -> 16f / 9f
            "SQUARE_1_1", "1:1" -> 1f
            "PORTRAIT_4_5", "4:5" -> 4f / 5f
            else -> 9f / 16f
        }

        val containerW = maxWidth
        val containerH = maxHeight
        val containerRatio = containerW / containerH

        val (targetW, targetH) = if (containerRatio > ratioFloat) {
            (containerH * ratioFloat) to containerH
        } else {
            containerW to (containerW / ratioFloat)
        }

        Box(
            modifier = Modifier
                .size(targetW, targetH)
                .clip(RoundedCornerShape(16.dp))
                .background(Color.Black)
                .clickable { onTogglePlayPause() }
        ) {
            // 1. Hardware Video Player
            if (player != null) {
                AndroidView(
                    modifier = Modifier.fillMaxSize(),
                    factory = { ctx ->
                        StyledPlayerView(ctx).apply {
                            useController = false
                            resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
                            this.player = player
                        }
                    },
                    update = { view ->
                        if (view.player != player) {
                            view.player = player
                        }
                    }
                )
            }

            // 2. Motion Graphics Viewport Overlay
            MotionGraphicsViewportOverlay(
                viewModel = viewModel,
                currentTimeMs = currentTimeMs,
                modifier = Modifier.fillMaxSize()
            )

            // 3. Floating Glassmorphism Player Controls Bar (Mute, Play/Pause, Fullscreen)
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .height(52.dp)
                    .background(
                        Brush.verticalGradient(
                            listOf(Color.Transparent, Color(0xCC090D16))
                        )
                    )
                    .padding(horizontal = 20.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    // Left: Volume / Mute Button
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .clickable { onToggleMute() },
                        contentAlignment = Alignment.Center
                    ) {
                        Video365Icons.Volume(isMuted = isMuted, tint = Color.White, size = 20.dp)
                    }

                    // Center: Large Play / Pause Button
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(CircleShape)
                            .background(Color.White.copy(alpha = 0.25f))
                            .border(width = 1.dp, color = Color.White.copy(alpha = 0.5f), shape = CircleShape)
                            .clickable { onTogglePlayPause() },
                        contentAlignment = Alignment.Center
                    ) {
                        if (isPlaying) {
                            Video365Icons.Pause(tint = Color.White, size = 20.dp)
                        } else {
                            Video365Icons.Play(tint = Color.White, size = 20.dp)
                        }
                    }

                    // Right: Fullscreen / Aspect Ratio Toggle Button
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .clickable {
                                // Toggle aspect ratio
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Video365Icons.Fullscreen(tint = Color.White, size = 20.dp)
                    }
                }
            }
        }
    }
}

/**
 * Bottom Tailwind Navigation Bar:
 * [T] Text, [♪] Music, [☺] Stickers, [✂] Split, [⚗] Filter
 */
@Composable
private fun EditorTailwindBottomBar(
    onTextClick: () -> Unit,
    onMusicClick: () -> Unit,
    onStickersClick: () -> Unit,
    onSplitClick: () -> Unit,
    onFilterClick: () -> Unit,
    onCommandsClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(68.dp)
            .background(Color(0xFF0F172A))
            .border(width = 0.5.dp, color = Color(0xFF1E293B))
            .padding(horizontal = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceAround
    ) {
        BottomNavItem(label = "Text", icon = { Video365Icons.Text(tint = it, size = 20.dp) }, onClick = onTextClick)
        BottomNavItem(label = "Music", icon = { Video365Icons.Music(tint = it, size = 20.dp) }, onClick = onMusicClick)
        BottomNavItem(label = "Stickers", icon = { Video365Icons.Sticker(tint = it, size = 20.dp) }, onClick = onStickersClick)
        BottomNavItem(label = "Split", icon = { Video365Icons.Split(tint = it, size = 20.dp) }, onClick = onSplitClick)
        BottomNavItem(label = "Filter", icon = { Video365Icons.Filter(tint = it, size = 20.dp) }, onClick = onFilterClick)
    }
}

@Composable
private fun BottomNavItem(
    label: String,
    icon: @Composable (Color) -> Unit,
    onClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .width(56.dp)
            .fillMaxHeight()
            .clickable { onClick() },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(34.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(Color(0xFF1E293B)),
            contentAlignment = Alignment.Center
        ) {
            icon(Color(0xFFE2E8F0))
        }
        Spacer(modifier = Modifier.height(3.dp))
        Text(
            text = label,
            color = Color(0xFF94A3B8),
            fontSize = 10.sp,
            fontWeight = FontWeight.Medium
        )
    }
}

/**
 * Add Extra Layer Bottom Sheet:
 * Lets user add Text, Audio, Sticker, Video, or Adjustment layer.
 */
@Composable
private fun AddLayerBottomSheet(
    onDismiss: () -> Unit,
    onSelectType: (String) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.65f))
            .clickable { onDismiss() },
        contentAlignment = Alignment.BottomCenter
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
                .background(Color(0xFF0F172A))
                .padding(24.dp)
        ) {
            Text(
                text = "Add Extra Layer",
                color = Color(0xFFF8FAFC),
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(16.dp))

            val options = listOf(
                Triple("Text Layer", "TEXT", "Add kinetic animated title or lower third"),
                Triple("Audio / Music", "AUDIO", "Add background music track or audio beat"),
                Triple("Sticker / Graphic", "SHAPE", "Add custom badge, sticker, or vector graphic"),
                Triple("Video Overlay (PiP)", "VIDEO", "Add Picture-in-Picture secondary video"),
                Triple("Adjustment Layer", "ADJUSTMENT", "Add Lumetri color grading and GPU vignette")
            )

            options.forEach { (title, type, desc) ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 6.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFF1E293B))
                        .clickable { onSelectType(type) }
                        .padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text(text = title, color = Color(0xFF06B6D4), fontSize = 14.sp, fontWeight = FontWeight.Bold)
                        Text(text = desc, color = Color(0xFF94A3B8), fontSize = 11.sp)
                    }
                    Video365Icons.Add(tint = Color(0xFF06B6D4), size = 18.dp)
                }
            }
        }
    }
}

/**
 * Export Modal Sheet matching Screen 2 of the reference image:
 * Sliders for Resolution and FPS, plus glowing "Download" button!
 */
@Composable
private fun ExportModalSheet(
    onDismiss: () -> Unit,
    onDownload: () -> Unit
) {
    var fpsValue by remember { mutableFloatStateOf(30f) }
    var resolutionValue by remember { mutableStateOf("1080p") }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.65f))
            .clickable { onDismiss() },
        contentAlignment = Alignment.BottomCenter
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
                .background(Color(0xFF0F172A))
                .padding(24.dp)
        ) {
            Text(
                text = "Export Settings",
                color = Color(0xFFF8FAFC),
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(20.dp))

            // Resolution Section
            Text(text = "Resolution", color = Color(0xFFE2E8F0), fontSize = 13.sp, fontWeight = FontWeight.Medium)
            Spacer(modifier = Modifier.height(10.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                listOf("540p", "720p", "1080p", "4K", "8K").forEach { res ->
                    val isSel = resolutionValue == res
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(if (isSel) Color(0xFF06B6D4) else Color(0xFF1E293B))
                            .clickable { resolutionValue = res }
                            .padding(horizontal = 12.dp, vertical = 8.dp)
                    ) {
                        Text(
                            text = res,
                            color = if (isSel) Color.Black else Color(0xFF94A3B8),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // FPS Rate Section
            Text(text = "FPS rate: ${fpsValue.toInt()} fps", color = Color(0xFFE2E8F0), fontSize = 13.sp, fontWeight = FontWeight.Medium)
            Spacer(modifier = Modifier.height(6.dp))
            Slider(
                value = fpsValue,
                onValueChange = { fpsValue = it },
                valueRange = 24f..60f,
                steps = 4,
                colors = SliderDefaults.colors(
                    thumbColor = Color(0xFF06B6D4),
                    activeTrackColor = Color(0xFF06B6D4),
                    inactiveTrackColor = Color(0xFF1E293B)
                )
            )
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                listOf("24", "30", "45", "50", "60").forEach {
                    Text(text = it, color = Color(0xFF64748B), fontSize = 10.sp)
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            // Download / Export Button
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(Color(0xFF06B6D4))
                    .clickable { onDownload() },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Download",
                    color = Color.Black,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
