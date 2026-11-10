package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.models.v2.Layer
import com.tharunbirla.librecuts.models.v2.RenderCacheSegment

@Composable
fun Timeline(
    layers: List<Layer>,
    currentTimeMs: Long,
    durationMs: Long,
    renderCacheSegments: List<RenderCacheSegment> = emptyList(),
    onSeek: (Long) -> Unit
) {
    val scrollState = rememberScrollState()
    val zoomLevel = 0.08f // pixels per ms

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF141414))
    ) {
        // Premiere Pro / AE Style Green Pre-render Cache Bar & Time Ruler
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFF222222))
        ) {
            // Pre-render segment status indicator
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .background(Color(0xFF333333))
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
                    // Default active preview cache line
                    Box(
                        modifier = Modifier
                            .fillMaxWidth(0.85f)
                            .fillMaxHeight()
                            .background(Color(0xFF00E676))
                    )
                }
            }

            // Time markers
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(24.dp)
                    .padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = String.format("%02d:%02d.%02d", (currentTimeMs / 60000), (currentTimeMs % 60000) / 1000, (currentTimeMs % 1000) / 10),
                    color = Color(0xFF00E676),
                    fontSize = 11.sp
                )
                Text(
                    text = "Smart 5s Segment Cache Active",
                    color = Color.LightGray,
                    fontSize = 9.sp
                )
                Text(
                    text = String.format("%02d:%02d.%02d", (durationMs / 60000), (durationMs % 60000) / 1000, (durationMs % 1000) / 10),
                    color = Color.Gray,
                    fontSize = 11.sp
                )
            }
        }

        // Multi-track Layers
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .horizontalScroll(scrollState)
        ) {
            Column(
                modifier = Modifier
                    .padding(vertical = 4.dp)
                    .clickable { /* seek */ }
            ) {
                layers.forEach { layer ->
                    LayerTrack(layer, zoomLevel)
                }
            }
            
            // Red Timeline Playhead
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .width(2.dp)
                    .offset(x = (currentTimeMs * zoomLevel).dp)
                    .background(Color(0xFFFF1744))
            )
        }
    }
}

@Composable
fun LayerTrack(layer: Layer, zoomLevel: Float) {
    val width = ((layer.outPointMs - layer.inPointMs) * zoomLevel).dp.coerceAtLeast(80.dp)
    val offset = (layer.inPointMs * zoomLevel).dp

    val trackColor = when (layer.type) {
        "ADJUSTMENT" -> Color(0xFFFF8F00) // Orange Lumetri
        "TEXT" -> Color(0xFF2E7D32)       // Green Kinetic Title
        "SHAPE" -> Color(0xFF00838F)      // Cyan Lower Third
        "VIDEO" -> Color(0xFF1565C0)      // Blue Main Video
        "AUDIO" -> Color(0xFF6A1B9A)      // Purple Audio
        else -> Color(0xFF424242)
    }

    val hasExpression = layer.transform.position.expressionEnabled && !layer.transform.position.expression.isNullOrEmpty()
    val hasTransition = layer.transitionOut != null
    val hasEffects = layer.effects.isNotEmpty()

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(38.dp)
            .padding(vertical = 2.dp)
    ) {
        Box(
            modifier = Modifier
                .offset(x = offset)
                .width(width)
                .fillMaxHeight()
                .background(trackColor, RoundedCornerShape(4.dp))
                .padding(horizontal = 8.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "${layer.type}: ${layer.layerId}",
                    color = Color.White,
                    fontSize = 11.sp,
                    maxLines = 1
                )
                
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    if (hasExpression) {
                        Box(
                            modifier = Modifier
                                .background(Color(0x88000000), RoundedCornerShape(2.dp))
                                .padding(horizontal = 4.dp, vertical = 1.dp)
                        ) {
                            Text("~ wiggle", color = Color(0xFFFFD54F), fontSize = 8.sp)
                        }
                    }
                    if (hasEffects) {
                        Box(
                            modifier = Modifier
                                .background(Color(0x88000000), RoundedCornerShape(2.dp))
                                .padding(horizontal = 4.dp, vertical = 1.dp)
                        ) {
                            Text("FX", color = Color(0xFF80D8FF), fontSize = 8.sp)
                        }
                    }
                    if (hasTransition) {
                        Box(
                            modifier = Modifier
                                .background(Color(0x88000000), RoundedCornerShape(2.dp))
                                .padding(horizontal = 4.dp, vertical = 1.dp)
                        ) {
                            Text("⚡ ${layer.transitionOut?.transitionId}", color = Color(0xFFFF8A80), fontSize = 8.sp)
                        }
                    }
                }
            }
        }
    }
}
