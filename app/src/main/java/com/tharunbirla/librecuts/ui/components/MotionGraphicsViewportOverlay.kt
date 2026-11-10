package com.tharunbirla.librecuts.ui.components

import android.graphics.Typeface
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.*
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.Video365Engine
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel
import java.io.File
import kotlin.math.sin

/**
 * Real-time Motion Graphics, GPU Shader Overlays, and Transition Compositor.
 * Renders directly over the hardware-accelerated 60fps video viewport.
 * Dynamically binds custom installed fonts (.ttf / .otf), text styling,
 * layer visibility toggles, and Premiere / AE keyframe expressions.
 */
@Composable
fun MotionGraphicsViewportOverlay(
    viewModel: Video365ViewModel,
    currentTimeMs: Long,
    modifier: Modifier = Modifier
) {
    val project by viewModel.project.collectAsState()
    val activeTransition by viewModel.activeTransition.collectAsState()
    val transitionProgress by viewModel.transitionProgress.collectAsState()
    val exposure by viewModel.exposure.collectAsState()
    val contrast by viewModel.contrast.collectAsState()
    val saturation by viewModel.saturation.collectAsState()
    val vignette by viewModel.vignette.collectAsState()
    val isDollyEnabled by viewModel.isDollyEnabled.collectAsState()

    val hiddenLayers by viewModel.hiddenLayerIds.collectAsState()
    val activeFontPath by viewModel.activeFontPath.collectAsState()
    val activeFontName by viewModel.activeFontName.collectAsState()
    val activeText by viewModel.activeTextContent.collectAsState()
    val activeColorHex by viewModel.activeTextColor.collectAsState()
    val activeFontSize by viewModel.activeFontSize.collectAsState()

    val comp = project?.compositions?.firstOrNull()
    val layers = comp?.layers ?: emptyList()

    val titleLayer = layers.find { it.type == "TEXT" || it.layerId.contains("title") }
    val lowerThirdLayer = layers.find { it.type == "SHAPE" || it.layerId.contains("lower_third") }
    val adjustmentLayer = layers.find { it.type == "ADJUSTMENT" || it.layerId.contains("adjustment") }

    val isTitleVisible = titleLayer != null && !hiddenLayers.contains(titleLayer.layerId) &&
            currentTimeMs >= titleLayer.inPointMs && currentTimeMs <= titleLayer.outPointMs

    val isLowerThirdVisible = lowerThirdLayer != null && !hiddenLayers.contains(lowerThirdLayer.layerId) &&
            currentTimeMs >= lowerThirdLayer.inPointMs && currentTimeMs <= lowerThirdLayer.outPointMs

    val isAdjustmentVisible = adjustmentLayer != null && !hiddenLayers.contains(adjustmentLayer.layerId) &&
            currentTimeMs >= adjustmentLayer.inPointMs && currentTimeMs <= adjustmentLayer.outPointMs

    val timeSec = currentTimeMs / 1000f

    // Dynamic Custom Typeface resolution
    val customFontFamily = remember(activeFontPath, activeFontName) {
        if (!activeFontPath.isNullOrBlank() && File(activeFontPath).exists()) {
            try {
                FontFamily(Typeface.createFromFile(activeFontPath))
            } catch (_: Exception) {
                FontFamily.Default
            }
        } else {
            when {
                activeFontName.contains("Cursive", ignoreCase = true) -> FontFamily.Cursive
                activeFontName.contains("Serif", ignoreCase = true) -> FontFamily.Serif
                activeFontName.contains("Mono", ignoreCase = true) -> FontFamily.Monospace
                else -> FontFamily.SansSerif
            }
        }
    }

    val dynamicTextColor = remember(activeColorHex) {
        try {
            Color(android.graphics.Color.parseColor(activeColorHex))
        } catch (_: Exception) {
            Color.White
        }
    }

    // Evaluate C++ AE Wiggle Expression dynamically
    val wiggleOffset = remember(currentTimeMs) {
        try {
            Video365Engine.evaluateExpressionFloat("wiggle(3.0, 20.0)", timeSec, 0f)
        } catch (_: Throwable) {
            (sin(timeSec.toDouble() * 3.0) * 15.0).toFloat()
        }
    }

    Box(modifier = modifier.fillMaxSize()) {
        // 1. Lumetri Color & Vignette Canvas Pass
        if (isAdjustmentVisible) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                val canvasWidth = size.width
                val canvasHeight = size.height

                // Vignette Shader Approximation
                if (vignette > 0.05f) {
                    val radius = (canvasWidth.coerceAtLeast(canvasHeight) / 2f) * (1.2f - (vignette * 0.4f))
                    val brush = Brush.radialGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = (vignette * 0.85f).coerceIn(0f, 1f))),
                        center = Offset(canvasWidth / 2f, canvasHeight / 2f),
                        radius = radius
                    )
                    drawRect(brush = brush, size = size)
                }

                // Exposure Filter
                if (exposure != 0f) {
                    val expAlpha = (exposure.coerceIn(-1f, 1f).let { if (it > 0) it * 0.35f else -it * 0.5f })
                    val expColor = if (exposure > 0) Color.White else Color.Black
                    drawRect(color = expColor.copy(alpha = expAlpha), size = size)
                }
            }
        }

        // 2. Real-time Transition Effects Preview Pass
        if (transitionProgress > 0.01f && activeTransition != null) {
            TransitionPreviewCanvas(
                transitionType = activeTransition ?: "whip_pan",
                progress = transitionProgress,
                modifier = Modifier.fillMaxSize()
            )
        }

        // 3. Motion Graphics: Kinetic Typography (AE Text Layer with Custom Font)
        if (isTitleVisible) {
            val titleText = titleLayer?.textData?.text?.ifBlank { activeText } ?: activeText
            val subtitleText = titleLayer?.textData?.subtitleText ?: "MOTION GRAPHICS & COMPOSITING"

            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = (80 + wiggleOffset).dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0x99090B10))
                    .border(1.dp, Brush.horizontalGradient(listOf(Color(0xFF00E5FF), Color(0xFF7C4DFF))), RoundedCornerShape(12.dp))
                    .padding(horizontal = 20.dp, vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = titleText,
                        color = dynamicTextColor,
                        fontSize = activeFontSize.sp,
                        fontFamily = customFontFamily,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                    if (!subtitleText.isNullOrBlank()) {
                        Text(
                            text = subtitleText,
                            color = Color(0xFF00E5FF),
                            fontSize = 10.sp,
                            fontFamily = customFontFamily,
                            fontWeight = FontWeight.SemiBold,
                            letterSpacing = 1.sp
                        )
                    }
                }
            }
        }

        // 4. Motion Graphics: Lower Third (AE Shape & Text Layer)
        if (isLowerThirdVisible) {
            val slideOffset = if (currentTimeMs - (lowerThirdLayer?.inPointMs ?: 0L) < 1000L) {
                ((1000L - (currentTimeMs - (lowerThirdLayer?.inPointMs ?: 0L))) / 1000f * 120f)
            } else 0f

            val lowerTitle = lowerThirdLayer?.textData?.text ?: "SARANGAN RAJENDRAN"
            val lowerSubtitle = lowerThirdLayer?.textData?.subtitleText ?: "VIDEO ARCHITECT & DIRECTOR"

            Box(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(start = 20.dp, bottom = (40 + slideOffset).dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(Color(0xCC0D111A))
                    .border(1.dp, Color(0xFF00E5FF).copy(alpha = 0.6f), RoundedCornerShape(8.dp))
                    .padding(horizontal = 14.dp, vertical = 8.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .width(4.dp)
                            .height(28.dp)
                            .clip(RoundedCornerShape(2.dp))
                            .background(Brush.verticalGradient(listOf(Color(0xFF00E5FF), Color(0xFF7C4DFF))))
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                    Column {
                        Text(
                            text = lowerTitle,
                            color = Color.White,
                            fontSize = 12.sp,
                            fontFamily = customFontFamily,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 1.sp
                        )
                        Text(
                            text = lowerSubtitle,
                            color = Color(0xFF90CAF9),
                            fontSize = 9.sp,
                            fontFamily = customFontFamily,
                            fontWeight = FontWeight.Normal
                        )
                    }
                }
            }
        }
    }
}

/**
 * Renders real-time shader visual transitions across the preview viewport.
 */
@Composable
private fun TransitionPreviewCanvas(
    transitionType: String,
    progress: Float,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height

        when (transitionType) {
            "whip_pan" -> {
                val sweepX = w * progress
                drawRect(
                    brush = Brush.horizontalGradient(
                        colors = listOf(Color.Transparent, Color(0xFF00E5FF).copy(alpha = 0.5f), Color.Black.copy(alpha = 0.8f), Color.Transparent),
                        startX = sweepX - 150f,
                        endX = sweepX + 150f
                    ),
                    topLeft = Offset(0f, 0f),
                    size = size
                )
            }
            "glitch" -> {
                val redAlpha = (progress * 0.7f).coerceIn(0f, 0.7f)
                val cyanAlpha = (progress * 0.7f).coerceIn(0f, 0.7f)
                val stepH = h / 12f
                for (i in 0..11) {
                    if (i % 2 == 0) {
                        drawRect(
                            color = Color.Red.copy(alpha = redAlpha),
                            topLeft = Offset((progress * 30f) * if (i % 4 == 0) 1 else -1, i * stepH),
                            size = Size(w, stepH)
                        )
                    } else {
                        drawRect(
                            color = Color.Cyan.copy(alpha = cyanAlpha),
                            topLeft = Offset((progress * -25f) * if (i % 4 == 0) 1 else -1, i * stepH),
                            size = Size(w, stepH)
                        )
                    }
                }
            }
            "doorway" -> {
                val openW = (w / 2f) * progress
                drawRect(
                    color = Color.Black.copy(alpha = 0.85f),
                    topLeft = Offset(0f, 0f),
                    size = Size(openW, h)
                )
                drawRect(
                    color = Color.Black.copy(alpha = 0.85f),
                    topLeft = Offset(w - openW, 0f),
                    size = Size(openW, h)
                )
            }
            "zoom" -> {
                val center = Offset(w / 2f, h / 2f)
                val maxRadius = (w.coerceAtLeast(h) / 2f)
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(Color.Transparent, Color(0xFF7C4DFF).copy(alpha = progress * 0.6f), Color.Black.copy(alpha = progress * 0.9f)),
                        center = center,
                        radius = maxRadius * (1f - (progress * 0.5f))
                    ),
                    center = center,
                    radius = maxRadius
                )
            }
            "film_burn" -> {
                val burnBrush = Brush.linearGradient(
                    colors = listOf(
                        Color(0xFFFF6D00).copy(alpha = progress * 0.7f),
                        Color(0xFFFFD600).copy(alpha = progress * 0.5f),
                        Color.Transparent
                    ),
                    start = Offset(0f, 0f),
                    end = Offset(w * progress * 1.5f, h * progress * 1.5f)
                )
                drawRect(brush = burnBrush, size = size)
            }
            "radial_blur" -> {
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(Color.Transparent, Color(0xFF00E5FF).copy(alpha = progress * 0.6f)),
                        radius = (w / 2f) * progress
                    ),
                    center = Offset(w / 2f, h / 2f),
                    radius = (w / 2f) * progress
                )
            }
            "wipe" -> {
                val wipeX = w * progress
                drawRect(
                    color = Color.Black.copy(alpha = 0.9f),
                    topLeft = Offset(0f, 0f),
                    size = Size(wipeX, h)
                )
            }
            "dissolve" -> {
                drawRect(
                    color = Color.Black.copy(alpha = progress * 0.85f),
                    size = size
                )
            }
            else -> {
                drawRect(
                    color = Color.Black.copy(alpha = progress * 0.5f),
                    size = size
                )
            }
        }
    }
}
