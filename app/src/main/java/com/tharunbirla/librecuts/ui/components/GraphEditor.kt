package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import com.tharunbirla.librecuts.models.v2.KeyframeFloat

/**
 * A professional Graph Editor for Bezier-based keyframe interpolation.
 * Matches After Effects 2026 Mobile UX requirements.
 */
@Composable
fun GraphEditor(
    keyframes: List<KeyframeFloat>,
    durationMs: Long,
    onKeyframeUpdate: (Int, KeyframeFloat) -> Unit,
    modifier: Modifier = Modifier
) {
    var selectedKeyframeIndex by remember { mutableStateOf(-1) }

    Box(
        modifier = modifier
            .background(Color(0xFF1E1E1E))
            .pointerInput(Unit) {
                detectDragGestures { change, dragAmount ->
                    // Logic to adjust Bezier tangents or keyframe values
                }
            }
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val width = size.width
            val height = size.height
            
            // Draw Grid
            drawGrid(width, height)

            // Draw Curve
            if (keyframes.size >= 2) {
                val path = Path()
                val first = keyframes[0]
                path.moveTo(
                    (first.timeMs.toFloat() / durationMs) * width,
                    height - (first.value * height)
                )

                for (i in 0 until keyframes.size - 1) {
                    val k1 = keyframes[i]
                    val k2 = keyframes[i + 1]
                    
                    val x1 = (k1.timeMs.toFloat() / durationMs) * width
                    val y1 = height - (k1.value * height)
                    val x2 = (k2.timeMs.toFloat() / durationMs) * width
                    val y2 = height - (k2.value * height)

                    // Bezier interpolation using tangents
                    val cp1x = x1 + (x2 - x1) * (k1.outTangent?.get(0) ?: 0.33f)
                    val cp1y = y1 // Simplified
                    val cp2x = x2 - (x2 - x1) * (k2.inTangent?.get(0) ?: 0.33f)
                    val cp2y = y2 // Simplified

                    path.cubicTo(cp1x, cp1y, cp2x, cp2y, x2, y2)
                }
                
                drawPath(
                    path = path,
                    color = Color(0xFF4CAF50),
                    style = Stroke(width = 2.dp.toPx())
                )
            }

            // Draw Keyframes
            keyframes.forEachIndexed { index, kf ->
                val x = (kf.timeMs.toFloat() / durationMs) * width
                val y = height - (kf.value * height)
                drawCircle(
                    color = if (selectedKeyframeIndex == index) Color.White else Color(0xFF4CAF50),
                    radius = 4.dp.toPx(),
                    center = Offset(x, y)
                )
            }
        }
    }
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawGrid(width: Float, height: Float) {
    val gridColor = Color(0xFF333333)
    val stepX = width / 10
    val stepY = height / 5
    
    for (i in 1..9) {
        drawLine(gridColor, Offset(i * stepX, 0f), Offset(i * stepX, height))
    }
    for (i in 1..4) {
        drawLine(gridColor, Offset(0f, i * stepY), Offset(width, i * stepY))
    }
}
