package com.tharunbirla.librecuts.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout
import com.google.android.exoplayer2.ui.StyledPlayerView
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel
import com.tharunbirla.librecuts.ui.components.Timeline
import com.tharunbirla.librecuts.ui.components.CommandBar
import com.tharunbirla.librecuts.ui.components.GraphEditor
import com.tharunbirla.librecuts.ui.components.EffectsAndTransitionsSheet
import com.tharunbirla.librecuts.ui.components.MotionGraphicsViewportOverlay
import com.tharunbirla.librecuts.ui.components.ScriptingConsoleSheet

/**
 * Adaptive Editor Workspace matching After Effects 2026 Mobile/Tablet requirements.
 * Features dual hardware video decoding + C++ GPU compositing layer.
 * Includes OpenCut Scripting Console & MCP tool bridge.
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
    
    var showCommandBar by remember { mutableStateOf(false) }
    var showEffectsSheet by remember { mutableStateOf(false) }
    var showHowToUse by remember { mutableStateOf(false) }
    var showScriptingConsole by remember { mutableStateOf(false) }

    val activePlayer = player ?: viewModel.player

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = Color(0xFF0D0F17)
    ) {
        if (isTablet) {
            TabletWorkspace(
                viewModel = viewModel,
                project = project,
                currentTimeMs = currentTimeMs,
                player = activePlayer,
                onOpenFX = { showEffectsSheet = true },
                onOpenGuide = { showHowToUse = true },
                onOpenScripting = { showScriptingConsole = true }
            )
        } else {
            PhoneWorkspace(
                viewModel = viewModel,
                project = project,
                currentTimeMs = currentTimeMs,
                player = activePlayer,
                onOpenCommandBar = { showCommandBar = true },
                onOpenFX = { showEffectsSheet = true },
                onOpenGuide = { showHowToUse = true },
                onOpenScripting = { showScriptingConsole = true }
            )
        }
        
        if (showCommandBar) {
            CommandBar(
                onDismiss = { showCommandBar = false },
                onOpenScripting = {
                    showCommandBar = false
                    showScriptingConsole = true
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

@Composable
fun PhoneWorkspace(
    viewModel: Video365ViewModel,
    project: com.tharunbirla.librecuts.models.v2.Video365Project?,
    currentTimeMs: Long,
    player: ExoPlayer?,
    onOpenCommandBar: () -> Unit = {},
    onOpenFX: () -> Unit = {},
    onOpenGuide: () -> Unit = {},
    onOpenScripting: () -> Unit = {}
) {
    Column(modifier = Modifier.fillMaxSize()) {
        // Preview Area with dynamic aspect ratio fit (16:9, 9:16, 1:1, 4:5, 4K, 1080p)
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1.5f)
                .background(Color(0xFF090A0F)),
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

            // Perfectly fit viewport bounds without letterbox clipping or overflow
            val (targetW, targetH) = if (containerRatio > ratioFloat) {
                (containerH * ratioFloat) to containerH
            } else {
                containerW to (containerW / ratioFloat)
            }

            Box(
                modifier = Modifier
                    .size(targetW, targetH)
                    .background(Color.Black)
                    .clipToBounds()
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

                // 2. Real-time C++ GLSL & Motion Graphics Overlay
                MotionGraphicsViewportOverlay(
                    viewModel = viewModel,
                    currentTimeMs = currentTimeMs,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }

        // Quick Controls & Tools Toolbar
        EditorToolbar(
            onOpenCommandBar = onOpenCommandBar,
            onOpenFX = onOpenFX,
            onOpenGuide = onOpenGuide,
            onOpenScripting = onOpenScripting
        )

        // Timeline Area
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
        ) {
            Timeline(
                layers = project?.compositions?.firstOrNull()?.layers ?: emptyList(),
                currentTimeMs = currentTimeMs,
                durationMs = project?.compositions?.firstOrNull()?.durationMs ?: 0L,
                renderCacheSegments = project?.compositions?.firstOrNull()?.renderCacheSegments ?: emptyList(),
                onSeek = { viewModel.seekTo(it) }
            )
        }
    }
}

@Composable
fun TabletWorkspace(
    viewModel: Video365ViewModel,
    project: com.tharunbirla.librecuts.models.v2.Video365Project?,
    currentTimeMs: Long,
    player: ExoPlayer?,
    onOpenFX: () -> Unit = {},
    onOpenGuide: () -> Unit = {},
    onOpenScripting: () -> Unit = {}
) {
    Row(modifier = Modifier.fillMaxSize()) {
        // Left Column: Monitor and Timeline
        Column(modifier = Modifier.weight(1f).fillMaxHeight()) {
            BoxWithConstraints(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .background(Color(0xFF090A0F)),
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
                        .background(Color.Black)
                        .clipToBounds()
                ) {
                    if (player != null) {
                        AndroidView(
                            modifier = Modifier.fillMaxSize(),
                            factory = { ctx ->
                                StyledPlayerView(ctx).apply {
                                    useController = false
                                    resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
                                    this.player = player
                                }
                            }
                        )
                    }
                    MotionGraphicsViewportOverlay(
                        viewModel = viewModel,
                        currentTimeMs = currentTimeMs,
                        modifier = Modifier.fillMaxSize()
                    )
                }
            }
            
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(300.dp)
            ) {
                Timeline(
                    layers = project?.compositions?.firstOrNull()?.layers ?: emptyList(),
                    currentTimeMs = currentTimeMs,
                    durationMs = project?.compositions?.firstOrNull()?.durationMs ?: 0L,
                    renderCacheSegments = project?.compositions?.firstOrNull()?.renderCacheSegments ?: emptyList(),
                    onSeek = { viewModel.seekTo(it) }
                )
            }
        }

        // Right Panel: Effect Controls / Graph Editor
        Column(
            modifier = Modifier
                .width(300.dp)
                .fillMaxHeight()
                .background(Color(0xFF141721))
        ) {
            Text("Effect Controls", color = Color.White, modifier = Modifier.padding(16.dp))
            HorizontalDivider(color = Color.DarkGray)
            Text("Graph Editor", color = Color.Gray, modifier = Modifier.padding(8.dp))
            GraphEditor(
                keyframes = emptyList(),
                durationMs = 5000L,
                onKeyframeUpdate = { _, _ -> },
                modifier = Modifier.height(200.dp).fillMaxWidth()
            )
        }
    }
}

@Composable
fun EditorToolbar(
    onOpenCommandBar: () -> Unit = {},
    onOpenFX: () -> Unit = {},
    onOpenGuide: () -> Unit = {},
    onOpenScripting: () -> Unit = {}
) {
    var aiZoomActive by remember { mutableStateOf(false) }
    
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(52.dp)
            .background(Color(0xFF141721))
            .padding(horizontal = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = "Trim",
                color = Color.LightGray,
                fontSize = 13.sp,
                modifier = Modifier.clickable { /* Trim action */ }
            )
            Text(
                text = "Split",
                color = Color.LightGray,
                fontSize = 13.sp,
                modifier = Modifier.clickable { /* Split action */ }
            )
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color(0xFF00E5FF).copy(alpha = 0.2f))
                    .clickable { onOpenFX() }
                    .padding(horizontal = 10.dp, vertical = 6.dp)
            ) {
                Text(
                    text = "FX & Transitions",
                    color = Color(0xFF00E5FF),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color(0xFF7C4DFF).copy(alpha = 0.2f))
                    .clickable { onOpenScripting() }
                    .padding(horizontal = 10.dp, vertical = 6.dp)
            ) {
                Text(
                    text = "REPL / Script",
                    color = Color(0xFFB388FF),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Text(
                text = if (aiZoomActive) "AI Zoom: 2x" else "AI Dolly",
                color = if (aiZoomActive) Color(0xFF00E5FF) else Color(0xFF8E95A5),
                fontSize = 12.sp,
                modifier = Modifier
                    .clickable {
                        aiZoomActive = !aiZoomActive
                        com.tharunbirla.librecuts.Video365Engine.setDollyZoom(if (aiZoomActive) 2.0f else 1.0f)
                    }
            )
        }

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
            IconButton(
                onClick = onOpenGuide,
                modifier = Modifier.size(36.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Info,
                    contentDescription = "How to Use Video365 Guide",
                    tint = Color(0xFF00E5FF)
                )
            }

            Button(
                onClick = onOpenCommandBar,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF222736)),
                shape = RoundedCornerShape(8.dp),
                contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                modifier = Modifier.height(34.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "Search Commands",
                    tint = Color.White,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text("Commands", color = Color.White, fontSize = 12.sp)
            }
        }
    }
}
