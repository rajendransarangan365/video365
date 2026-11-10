package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Free vector icon pack in modern Tailwind / Lucide aesthetic.
 * 100% self-contained, crash-free, zero external icon dependencies.
 */
object Video365Icons {

    @Composable
    fun Play(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val path = Path().apply {
                moveTo(w * 0.28f, h * 0.18f)
                lineTo(w * 0.82f, h * 0.50f)
                lineTo(w * 0.28f, h * 0.82f)
                close()
            }
            drawPath(path, color = tint, style = Fill)
        }
    }

    @Composable
    fun Pause(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val barW = w * 0.22f
            val r = barW * 0.4f
            drawRoundRect(
                color = tint,
                topLeft = Offset(w * 0.22f, h * 0.2f),
                size = Size(barW, h * 0.6f),
                cornerRadius = CornerRadius(r, r)
            )
            drawRoundRect(
                color = tint,
                topLeft = Offset(w * 0.56f, h * 0.2f),
                size = Size(barW, h * 0.6f),
                cornerRadius = CornerRadius(r, r)
            )
        }
    }

    @Composable
    fun Volume(isMuted: Boolean = false, tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            
            // Speaker cone
            val path = Path().apply {
                moveTo(w * 0.15f, h * 0.38f)
                lineTo(w * 0.32f, h * 0.38f)
                lineTo(w * 0.52f, h * 0.20f)
                lineTo(w * 0.52f, h * 0.80f)
                lineTo(w * 0.32f, h * 0.62f)
                lineTo(w * 0.15f, h * 0.62f)
                close()
            }
            drawPath(path, color = tint, style = Fill)

            if (isMuted) {
                // Slash through
                drawLine(
                    color = Color(0xFFEF4444),
                    start = Offset(w * 0.65f, h * 0.35f),
                    end = Offset(w * 0.88f, h * 0.65f),
                    strokeWidth = strokeW,
                    cap = StrokeCap.Round
                )
                drawLine(
                    color = Color(0xFFEF4444),
                    start = Offset(w * 0.88f, h * 0.35f),
                    end = Offset(w * 0.65f, h * 0.65f),
                    strokeWidth = strokeW,
                    cap = StrokeCap.Round
                )
            } else {
                // Sound waves
                drawArc(
                    color = tint,
                    startAngle = -45f,
                    sweepAngle = 90f,
                    useCenter = false,
                    topLeft = Offset(w * 0.45f, h * 0.30f),
                    size = Size(w * 0.35f, h * 0.40f),
                    style = Stroke(width = strokeW, cap = StrokeCap.Round)
                )
            }
        }
    }

    @Composable
    fun Fullscreen(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            val arm = w * 0.22f

            // Top-left
            drawLine(tint, Offset(w * 0.18f, h * 0.18f + arm), Offset(w * 0.18f, h * 0.18f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.18f, h * 0.18f), Offset(w * 0.18f + arm, h * 0.18f), strokeW, StrokeCap.Round)
            // Top-right
            drawLine(tint, Offset(w * 0.82f - arm, h * 0.18f), Offset(w * 0.82f, h * 0.18f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.82f, h * 0.18f), Offset(w * 0.82f, h * 0.18f + arm), strokeW, StrokeCap.Round)
            // Bottom-left
            drawLine(tint, Offset(w * 0.18f, h * 0.82f - arm), Offset(w * 0.18f, h * 0.82f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.18f, h * 0.82f), Offset(w * 0.18f + arm, h * 0.82f), strokeW, StrokeCap.Round)
            // Bottom-right
            drawLine(tint, Offset(w * 0.82f - arm, h * 0.82f), Offset(w * 0.82f, h * 0.82f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.82f, h * 0.82f), Offset(w * 0.82f, h * 0.82f - arm), strokeW, StrokeCap.Round)
        }
    }

    @Composable
    fun Undo(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.8f)

            // Curved arc
            drawArc(
                color = tint,
                startAngle = 180f,
                sweepAngle = 160f,
                useCenter = false,
                topLeft = Offset(w * 0.25f, h * 0.35f),
                size = Size(w * 0.55f, h * 0.50f),
                style = Stroke(width = strokeW, cap = StrokeCap.Round)
            )
            // Arrow head
            val arrowPath = Path().apply {
                moveTo(w * 0.15f, h * 0.48f)
                lineTo(w * 0.28f, h * 0.30f)
                lineTo(w * 0.38f, h * 0.48f)
            }
            drawPath(arrowPath, color = tint, style = Stroke(width = strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
    }

    @Composable
    fun Redo(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.8f)

            // Curved arc
            drawArc(
                color = tint,
                startAngle = -20f,
                sweepAngle = 160f,
                useCenter = false,
                topLeft = Offset(w * 0.20f, h * 0.35f),
                size = Size(w * 0.55f, h * 0.50f),
                style = Stroke(width = strokeW, cap = StrokeCap.Round)
            )
            // Arrow head
            val arrowPath = Path().apply {
                moveTo(w * 0.62f, h * 0.48f)
                lineTo(w * 0.72f, h * 0.30f)
                lineTo(w * 0.85f, h * 0.48f)
            }
            drawPath(arrowPath, color = tint, style = Stroke(width = strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
    }

    @Composable
    fun Add(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.10f).coerceAtLeast(2f)
            drawLine(tint, Offset(w * 0.2f, h * 0.5f), Offset(w * 0.8f, h * 0.5f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.5f, h * 0.2f), Offset(w * 0.5f, h * 0.8f), strokeW, StrokeCap.Round)
        }
    }

    @Composable
    fun Back(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.8f)
            val path = Path().apply {
                moveTo(w * 0.65f, h * 0.22f)
                lineTo(w * 0.35f, h * 0.50f)
                lineTo(w * 0.65f, h * 0.78f)
            }
            drawPath(path, color = tint, style = Stroke(width = strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
    }

    @Composable
    fun Check(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.10f).coerceAtLeast(2f)
            val path = Path().apply {
                moveTo(w * 0.22f, h * 0.52f)
                lineTo(w * 0.44f, h * 0.74f)
                lineTo(w * 0.80f, h * 0.26f)
            }
            drawPath(path, color = tint, style = Stroke(width = strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
    }

    @Composable
    fun Music(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.6f)
            // Musical note noteheads and stems
            drawCircle(tint, radius = w * 0.12f, center = Offset(w * 0.32f, h * 0.72f))
            drawCircle(tint, radius = w * 0.12f, center = Offset(w * 0.72f, h * 0.62f))
            drawLine(tint, Offset(w * 0.42f, h * 0.72f), Offset(w * 0.42f, h * 0.26f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.82f, h * 0.62f), Offset(w * 0.82f, h * 0.18f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.42f, h * 0.26f), Offset(w * 0.82f, h * 0.18f), strokeW * 1.5f, StrokeCap.Round)
        }
    }

    @Composable
    fun Text(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.11f).coerceAtLeast(2f)
            // Top crossbar
            drawLine(tint, Offset(w * 0.20f, h * 0.25f), Offset(w * 0.80f, h * 0.25f), strokeW, StrokeCap.Round)
            // Vertical stem
            drawLine(tint, Offset(w * 0.50f, h * 0.25f), Offset(w * 0.50f, h * 0.80f), strokeW, StrokeCap.Round)
        }
    }

    @Composable
    fun Camera(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            // Camera body
            drawRoundRect(
                color = tint,
                topLeft = Offset(w * 0.15f, h * 0.30f),
                size = Size(w * 0.50f, h * 0.42f),
                cornerRadius = CornerRadius(w * 0.08f, w * 0.08f),
                style = Stroke(width = strokeW)
            )
            // Lens triangle
            val lens = Path().apply {
                moveTo(w * 0.68f, h * 0.40f)
                lineTo(w * 0.88f, h * 0.28f)
                lineTo(w * 0.88f, h * 0.74f)
                lineTo(w * 0.68f, h * 0.62f)
                close()
            }
            drawPath(lens, color = tint, style = Fill)
        }
    }

    @Composable
    fun Sticker(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            // Circle face
            drawCircle(tint, radius = w * 0.38f, center = Offset(w * 0.5f, h * 0.5f), style = Stroke(width = strokeW))
            // Eyes
            drawCircle(tint, radius = w * 0.045f, center = Offset(w * 0.38f, h * 0.42f))
            drawCircle(tint, radius = w * 0.045f, center = Offset(w * 0.62f, h * 0.42f))
            // Smile
            drawArc(
                color = tint,
                startAngle = 20f,
                sweepAngle = 140f,
                useCenter = false,
                topLeft = Offset(w * 0.32f, h * 0.48f),
                size = Size(w * 0.36f, h * 0.24f),
                style = Stroke(width = strokeW, cap = StrokeCap.Round)
            )
        }
    }

    @Composable
    fun Split(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            // Left bracket
            drawLine(tint, Offset(w * 0.30f, h * 0.22f), Offset(w * 0.30f, h * 0.78f), strokeW, StrokeCap.Round)
            // Right bracket
            drawLine(tint, Offset(w * 0.70f, h * 0.22f), Offset(w * 0.70f, h * 0.78f), strokeW, StrokeCap.Round)
            // Dashed or dotted center cut line
            drawLine(Color(0xFF06B6D4), Offset(w * 0.50f, h * 0.16f), Offset(w * 0.50f, h * 0.84f), strokeW * 1.2f, StrokeCap.Round)
        }
    }

    @Composable
    fun Filter(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            // Laboratory Flask / Sparkles
            val flask = Path().apply {
                moveTo(w * 0.42f, h * 0.18f)
                lineTo(w * 0.58f, h * 0.18f)
                lineTo(w * 0.58f, h * 0.42f)
                lineTo(w * 0.80f, h * 0.80f)
                lineTo(w * 0.20f, h * 0.80f)
                lineTo(w * 0.42f, h * 0.42f)
                close()
            }
            drawPath(flask, color = tint, style = Stroke(width = strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
            // Liquid inside
            val liquid = Path().apply {
                moveTo(w * 0.30f, h * 0.65f)
                lineTo(w * 0.70f, h * 0.65f)
                lineTo(w * 0.78f, h * 0.78f)
                lineTo(w * 0.22f, h * 0.78f)
                close()
            }
            drawPath(liquid, color = Color(0xFF06B6D4), style = Fill)
        }
    }

    @Composable
    fun Gallery(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            // Frame
            drawRoundRect(
                color = tint,
                topLeft = Offset(w * 0.16f, h * 0.18f),
                size = Size(w * 0.68f, h * 0.64f),
                cornerRadius = CornerRadius(w * 0.08f, w * 0.08f),
                style = Stroke(width = strokeW)
            )
            // Sun/Moon
            drawCircle(tint, radius = w * 0.07f, center = Offset(w * 0.36f, h * 0.38f))
            // Mountains
            val mtn = Path().apply {
                moveTo(w * 0.22f, h * 0.76f)
                lineTo(w * 0.44f, h * 0.52f)
                lineTo(w * 0.56f, h * 0.64f)
                lineTo(w * 0.68f, h * 0.48f)
                lineTo(w * 0.78f, h * 0.76f)
            }
            drawPath(mtn, color = tint, style = Stroke(width = strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
    }

    @Composable
    fun PrevFrame(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.10f).coerceAtLeast(1.8f)
            // Left vertical line
            drawLine(tint, Offset(w * 0.22f, h * 0.22f), Offset(w * 0.22f, h * 0.78f), strokeW, StrokeCap.Round)
            // Left triangle
            val path = Path().apply {
                moveTo(w * 0.78f, h * 0.22f)
                lineTo(w * 0.35f, h * 0.50f)
                lineTo(w * 0.78f, h * 0.78f)
                close()
            }
            drawPath(path, color = tint, style = Fill)
        }
    }

    @Composable
    fun NextFrame(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.10f).coerceAtLeast(1.8f)
            // Right triangle
            val path = Path().apply {
                moveTo(w * 0.22f, h * 0.22f)
                lineTo(w * 0.65f, h * 0.50f)
                lineTo(w * 0.22f, h * 0.78f)
                close()
            }
            drawPath(path, color = tint, style = Fill)
            // Right vertical line
            drawLine(tint, Offset(w * 0.78f, h * 0.22f), Offset(w * 0.78f, h * 0.78f), strokeW, StrokeCap.Round)
        }
    }

    @Composable
    fun ZoomIn(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.6f)
            // Glass circle
            drawCircle(tint, radius = w * 0.30f, center = Offset(w * 0.42f, h * 0.42f), style = Stroke(strokeW))
            // Handle
            drawLine(tint, Offset(w * 0.64f, h * 0.64f), Offset(w * 0.86f, h * 0.86f), strokeW * 1.3f, StrokeCap.Round)
            // Plus
            drawLine(tint, Offset(w * 0.30f, h * 0.42f), Offset(w * 0.54f, h * 0.42f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.42f, h * 0.30f), Offset(w * 0.42f, h * 0.54f), strokeW, StrokeCap.Round)
        }
    }

    @Composable
    fun ZoomOut(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.6f)
            // Glass circle
            drawCircle(tint, radius = w * 0.30f, center = Offset(w * 0.42f, h * 0.42f), style = Stroke(strokeW))
            // Handle
            drawLine(tint, Offset(w * 0.64f, h * 0.64f), Offset(w * 0.86f, h * 0.86f), strokeW * 1.3f, StrokeCap.Round)
            // Minus
            drawLine(tint, Offset(w * 0.30f, h * 0.42f), Offset(w * 0.54f, h * 0.42f), strokeW, StrokeCap.Round)
        }
    }

    @Composable
    fun Magnet(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.12f).coerceAtLeast(2f)
            // U-shape magnet
            drawArc(
                color = tint,
                startAngle = 0f,
                sweepAngle = 180f,
                useCenter = false,
                topLeft = Offset(w * 0.22f, h * 0.35f),
                size = Size(w * 0.56f, h * 0.45f),
                style = Stroke(strokeW, cap = StrokeCap.Butt)
            )
            drawLine(tint, Offset(w * 0.22f, h * 0.20f), Offset(w * 0.22f, h * 0.58f), strokeW, StrokeCap.Butt)
            drawLine(tint, Offset(w * 0.78f, h * 0.20f), Offset(w * 0.78f, h * 0.58f), strokeW, StrokeCap.Butt)
            // Poles (red/cyan)
            drawLine(Color(0xFFEF4444), Offset(w * 0.22f, h * 0.18f), Offset(w * 0.22f, h * 0.28f), strokeW, StrokeCap.Butt)
            drawLine(Color(0xFF06B6D4), Offset(w * 0.78f, h * 0.18f), Offset(w * 0.78f, h * 0.28f), strokeW, StrokeCap.Butt)
        }
    }

    @Composable
    fun Crop(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.8f)
            // Top-left bracket
            drawLine(tint, Offset(w * 0.15f, h * 0.35f), Offset(w * 0.75f, h * 0.35f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.35f, h * 0.15f), Offset(w * 0.35f, h * 0.75f), strokeW, StrokeCap.Round)
            // Bottom-right bracket
            drawLine(tint, Offset(w * 0.25f, h * 0.65f), Offset(w * 0.85f, h * 0.65f), strokeW, StrokeCap.Round)
            drawLine(tint, Offset(w * 0.65f, h * 0.25f), Offset(w * 0.65f, h * 0.85f), strokeW, StrokeCap.Round)
        }
    }

    @Composable
    fun Speed(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.08f).coerceAtLeast(1.5f)
            // Gauge arc
            drawArc(
                color = tint,
                startAngle = 140f,
                sweepAngle = 260f,
                useCenter = false,
                topLeft = Offset(w * 0.18f, h * 0.18f),
                size = Size(w * 0.64f, h * 0.64f),
                style = Stroke(strokeW, cap = StrokeCap.Round)
            )
            // Needle
            drawLine(Color(0xFF06B6D4), Offset(w * 0.5f, h * 0.5f), Offset(w * 0.68f, h * 0.32f), strokeW * 1.2f, StrokeCap.Round)
            drawCircle(tint, radius = w * 0.06f, center = Offset(w * 0.5f, h * 0.5f))
        }
    }

    @Composable
    fun Keyframe(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.8f)
            // Diamond / Rhombus
            val path = Path().apply {
                moveTo(w * 0.5f, h * 0.18f)
                lineTo(w * 0.82f, h * 0.5f)
                lineTo(w * 0.5f, h * 0.82f)
                lineTo(w * 0.18f, h * 0.5f)
                close()
            }
            drawPath(path, color = tint, style = Stroke(strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
    }

    @Composable
    fun Layers(tint: Color = Color.White, size: Dp = 20.dp, modifier: Modifier = Modifier) {
        Canvas(modifier = modifier.size(size)) {
            val w = this.size.width
            val h = this.size.height
            val strokeW = (w * 0.09f).coerceAtLeast(1.8f)
            // Top rhomboid layer
            val topP = Path().apply {
                moveTo(w * 0.5f, h * 0.18f)
                lineTo(w * 0.85f, h * 0.35f)
                lineTo(w * 0.5f, h * 0.52f)
                lineTo(w * 0.15f, h * 0.35f)
                close()
            }
            drawPath(topP, color = tint, style = Stroke(strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
            // Bottom chevron
            val botP = Path().apply {
                moveTo(w * 0.15f, h * 0.55f)
                lineTo(w * 0.5f, h * 0.72f)
                lineTo(w * 0.85f, h * 0.55f)
            }
            drawPath(botP, color = tint, style = Stroke(strokeW, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
    }
}

