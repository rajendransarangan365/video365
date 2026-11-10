package com.tharunbirla.librecuts.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog

/**
 * In-App Instructions Guide explaining how to use Video365.
 * Demonstrates the 6 core systems: Multi-track timeline, GPU Transitions,
 * Lumetri Color, AE Expressions, Zero-heating 4K proxies, and OpenCut Scripting/MCP.
 */
@Composable
fun HowToUseDialog(
    onDismiss: () -> Unit,
    onLaunchDemoProject: () -> Unit
) {
    val scrollState = rememberScrollState()

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 16.dp),
            shape = RoundedCornerShape(20.dp),
            color = Color(0xFF141721),
            tonalElevation = 8.dp
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp)
            ) {
                // Title Header
                Text(
                    text = "How to Use Video365",
                    color = Color.White,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Desktop-grade motion graphics & editing on mobile",
                    color = Color(0xFF00E5FF),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )

                Spacer(modifier = Modifier.height(14.dp))

                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f, fill = false)
                        .heightIn(max = 380.dp)
                        .verticalScroll(scrollState)
                ) {
                    GuideItem(
                        step = "1",
                        title = "Aspect Ratios & Auto-Fit",
                        desc = "Create projects in 9:16 (Vertical), 16:9 (Landscape), 1:1 (Square), or 4:5. Any 4K or 1080p footage cleanly auto-fits with zero distortion and zero black screen. High bitrate media automatically plays via hardware decoding."
                    )
                    GuideItem(
                        step = "2",
                        title = "10 GPU Transitions",
                        desc = "Tap 'FX & Transitions' to apply GPU-accelerated Whip Pan, Glitch RGB, 3D Doorway, Dynamic Zoom, Film Burn, Radial Blur, Swirl Vortex, Water Wave, Linear Wipe, or Dissolve with live progress scrub."
                    )
                    GuideItem(
                        step = "3",
                        title = "Lumetri Color & Chroma Key",
                        desc = "Grade footage with live Exposure, Contrast, Saturation, and Lens Vignette sliders. Enable the Green Screen Chroma Key switch for studio background removal."
                    )
                    GuideItem(
                        step = "4",
                        title = "Motion Graphics & AE Expressions",
                        desc = "Add dynamic Kinetic Titles and Lower Thirds powered by After Effects math expressions like wiggle(3.0, 25.0) and cubic Bezier easing curves."
                    )
                    GuideItem(
                        step = "5",
                        title = "Render on the Go (Zero Heating)",
                        desc = "Timeline tracks are divided into 5-second segments. When idle, complex segments pre-render in the background with Android Thermal API preventing device heat."
                    )
                    GuideItem(
                        step = "6",
                        title = "OpenCut Scripting & AI Bridge",
                        desc = "Tap 'Script' to execute JSX / ExtendScript commands, auto-remove silence with waveform detection, or interact with external AI agents via Model Context Protocol (MCP)."
                    )
                    GuideItem(
                        step = "7",
                        title = "Layer Moving & Track Trimming",
                        desc = "Drag any clip body horizontally across the timeline to move it across time. Drag the '<' and '>' cyan handles to trim in-point and out-point. Tap track icons to toggle visibility (eye) or mute audio."
                    )
                    GuideItem(
                        step = "8",
                        title = "Install Custom Fonts (.ttf / .otf)",
                        desc = "Tap 'Fonts' or 'T Font' to pick from trending typography presets or tap 'Install Custom Font' to select and install ANY .ttf or .otf font file directly from your device storage."
                    )
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Actions
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedButton(
                        onClick = onDismiss,
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(10.dp),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color(0xFFA0A6B5)),
                        border = androidx.compose.foundation.BorderStroke(1.dp, Color(0xFF2C3243))
                    ) {
                        Text("Close", fontSize = 13.sp)
                    }

                    Button(
                        onClick = {
                            onDismiss()
                            onLaunchDemoProject()
                        },
                        modifier = Modifier.weight(1.5f),
                        shape = RoundedCornerShape(10.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00E5FF))
                    ) {
                        Text("Open Demo Project", color = Color.Black, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

@Composable
private fun GuideItem(step: String, title: String, desc: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .clip(RoundedCornerShape(10.dp))
            .background(Color(0xFF0D0F17))
            .border(0.5.dp, Color(0xFF232838), RoundedCornerShape(10.dp))
            .padding(12.dp),
        verticalAlignment = Alignment.Top
    ) {
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(RoundedCornerShape(6.dp))
                .background(Color(0xFF00E5FF).copy(alpha = 0.2f)),
            contentAlignment = Alignment.Center
        ) {
            Text(step, color = Color(0xFF00E5FF), fontSize = 12.sp, fontWeight = FontWeight.Bold)
        }

        Spacer(modifier = Modifier.width(10.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(title, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
            Spacer(modifier = Modifier.height(2.dp))
            Text(desc, color = Color(0xFF8E95A5), fontSize = 11.sp, lineHeight = 15.sp)
        }
    }
}
