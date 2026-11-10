package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.Video365Engine
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel

/**
 * Mobile CapCut / Premiere Pro-style Bottom Sheet for Transitions, GPU Effects & Motion Graphics.
 * Professional studio UI: Zero emojis, real interactive sliders, instant GPU feedback.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EffectsAndTransitionsSheet(
    viewModel: Video365ViewModel,
    onDismiss: () -> Unit
) {
    var selectedTab by remember { mutableStateOf(0) } // 0 = Transitions, 1 = Effects, 2 = Motion Graphics
    val tabs = listOf("Transitions", "GPU Effects", "Motion Graphics")

    // Transition state
    var activeTransition by remember { mutableStateOf("whip_pan") }
    var transitionProgress by remember { mutableStateOf(0.5f) }
    var transitionDurationMs by remember { mutableStateOf(600L) }

    // Effects state (Lumetri & Stylize)
    var exposure by remember { mutableStateOf(0.0f) }
    var contrast by remember { mutableStateOf(1.0f) }
    var saturation by remember { mutableStateOf(1.0f) }
    var vignetteRadius by remember { mutableStateOf(0.8f) }
    var chromaKeyEnabled by remember { mutableStateOf(false) }
    var chromaThreshold by remember { mutableStateOf(0.4f) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = Color(0xFF141721),
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp),
        dragHandle = { BottomSheetDefaults.DragHandle(color = Color(0xFF4E5569)) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            // Header / Tabs
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFF0D0F17))
                    .padding(4.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                tabs.forEachIndexed { index, title ->
                    val isSelected = selectedTab == index
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(8.dp))
                            .background(if (isSelected) Color(0xFF00E5FF).copy(alpha = 0.15f) else Color.Transparent)
                            .clickable { selectedTab = index }
                            .padding(vertical = 10.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = title,
                            color = if (isSelected) Color(0xFF00E5FF) else Color(0xFF8E95A5),
                            fontSize = 13.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            when (selectedTab) {
                0 -> {
                    // Transitions Tab
                    TransitionsTabContent(
                        activeTransition = activeTransition,
                        progress = transitionProgress,
                        onTransitionSelect = { name ->
                            activeTransition = name
                            Video365Engine.setTransition(name, transitionProgress)
                            viewModel.applyTransition(name, transitionProgress)
                        },
                        onProgressChange = { p ->
                            transitionProgress = p
                            Video365Engine.setTransition(activeTransition, p)
                            viewModel.applyTransition(activeTransition, p)
                        }
                    )
                }
                1 -> {
                    // GPU Effects & Color Grading Tab
                    EffectsTabContent(
                        exposure = exposure,
                        contrast = contrast,
                        saturation = saturation,
                        vignetteRadius = vignetteRadius,
                        chromaKeyEnabled = chromaKeyEnabled,
                        chromaThreshold = chromaThreshold,
                        onExposureChange = { 
                            exposure = it
                            viewModel.setExposure(it)
                        },
                        onContrastChange = { 
                            contrast = it
                            viewModel.setContrast(it)
                        },
                        onSaturationChange = { 
                            saturation = it
                            viewModel.setSaturation(it)
                        },
                        onVignetteChange = { 
                            vignetteRadius = it
                            viewModel.setVignette(it)
                        },
                        onChromaToggle = { 
                            chromaKeyEnabled = it
                            viewModel.setChromaKey(it, chromaThreshold)
                        },
                        onChromaThresholdChange = { 
                            chromaThreshold = it
                            viewModel.setChromaKey(chromaKeyEnabled, it)
                        }
                    )
                }
                2 -> {
                    // Motion Graphics JSX Tab
                    MotionGraphicsTabContent(
                        onSelectPreset = { presetName ->
                            viewModel.addPresetLayer(presetName)
                            onDismiss()
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
private fun TransitionsTabContent(
    activeTransition: String,
    progress: Float,
    onTransitionSelect: (String) -> Unit,
    onProgressChange: (Float) -> Unit
) {
    val transitions = listOf(
        "whip_pan" to "Whip Pan",
        "glitch" to "Glitch RGB",
        "doorway" to "3D Doorway",
        "zoom" to "Dynamic Zoom",
        "film_burn" to "Film Burn",
        "radial_blur" to "Radial Blur",
        "swirl" to "Swirl Vortex",
        "wave" to "Water Wave",
        "wipe" to "Linear Wipe",
        "dissolve" to "Cross Dissolve"
    )

    Column(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = "Select Transition Effect",
            color = Color.White,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold
        )

        Spacer(modifier = Modifier.height(10.dp))

        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            items(transitions) { (id, name) ->
                val isSelected = activeTransition == id
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(10.dp))
                        .background(if (isSelected) Color(0xFF1F293D) else Color(0xFF161922))
                        .border(
                            width = if (isSelected) 1.5.dp else 0.5.dp,
                            color = if (isSelected) Color(0xFF00E5FF) else Color(0xFF2C3243),
                            shape = RoundedCornerShape(10.dp)
                        )
                        .clickable { onTransitionSelect(id) }
                        .padding(horizontal = 14.dp, vertical = 12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = name,
                        color = if (isSelected) Color.White else Color(0xFFA0A6B5),
                        fontSize = 12.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Progress / Timeline Scrubbing Slider
        Text(
            text = "Transition Progress: ${(progress * 100).toInt()}%",
            color = Color(0xFFA0A6B5),
            fontSize = 12.sp
        )
        Slider(
            value = progress,
            onValueChange = onProgressChange,
            valueRange = 0.0f..1.0f,
            colors = SliderDefaults.colors(
                thumbColor = Color(0xFF00E5FF),
                activeTrackColor = Color(0xFF00E5FF),
                inactiveTrackColor = Color(0xFF2A2E3D)
            )
        )
    }
}

@Composable
private fun EffectsTabContent(
    exposure: Float,
    contrast: Float,
    saturation: Float,
    vignetteRadius: Float,
    chromaKeyEnabled: Boolean,
    chromaThreshold: Float,
    onExposureChange: (Float) -> Unit,
    onContrastChange: (Float) -> Unit,
    onSaturationChange: (Float) -> Unit,
    onVignetteChange: (Float) -> Unit,
    onChromaToggle: (Boolean) -> Unit,
    onChromaThresholdChange: (Float) -> Unit
) {
    val scrollState = rememberScrollState()
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(max = 280.dp)
            .verticalScroll(scrollState)
    ) {
        // Lumetri Section
        Text(
            text = "Lumetri Color Grading",
            color = Color.White,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Exposure
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Exposure", color = Color(0xFFA0A6B5), fontSize = 12.sp)
            Text(String.format("%.2f EV", exposure), color = Color(0xFF00E5FF), fontSize = 12.sp)
        }
        Slider(
            value = exposure,
            onValueChange = onExposureChange,
            valueRange = -2.0f..2.0f,
            colors = SliderDefaults.colors(thumbColor = Color(0xFF00E5FF), activeTrackColor = Color(0xFF00E5FF))
        )

        // Contrast
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Contrast", color = Color(0xFFA0A6B5), fontSize = 12.sp)
            Text(String.format("%.2f", contrast), color = Color(0xFF00E5FF), fontSize = 12.sp)
        }
        Slider(
            value = contrast,
            onValueChange = onContrastChange,
            valueRange = 0.5f..1.8f,
            colors = SliderDefaults.colors(thumbColor = Color(0xFF00E5FF), activeTrackColor = Color(0xFF00E5FF))
        )

        // Saturation
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Saturation", color = Color(0xFFA0A6B5), fontSize = 12.sp)
            Text(String.format("%.2f", saturation), color = Color(0xFF00E5FF), fontSize = 12.sp)
        }
        Slider(
            value = saturation,
            onValueChange = onSaturationChange,
            valueRange = 0.0f..2.0f,
            colors = SliderDefaults.colors(thumbColor = Color(0xFF00E5FF), activeTrackColor = Color(0xFF00E5FF))
        )

        // Vignette
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Lens Vignette", color = Color(0xFFA0A6B5), fontSize = 12.sp)
            Text(String.format("%.2f", vignetteRadius), color = Color(0xFF00E5FF), fontSize = 12.sp)
        }
        Slider(
            value = vignetteRadius,
            onValueChange = onVignetteChange,
            valueRange = 0.2f..1.2f,
            colors = SliderDefaults.colors(thumbColor = Color(0xFF00E5FF), activeTrackColor = Color(0xFF00E5FF))
        )

        Spacer(modifier = Modifier.height(12.dp))

        // Chroma Key Section
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Green Screen Chroma Key",
                color = Color.White,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium
            )
            Switch(
                checked = chromaKeyEnabled,
                onCheckedChange = onChromaToggle,
                colors = SwitchDefaults.colors(checkedThumbColor = Color(0xFF00E5FF))
            )
        }

        if (chromaKeyEnabled) {
            Text(
                text = "Tolerance Threshold: ${(chromaThreshold * 100).toInt()}%",
                color = Color(0xFFA0A6B5),
                fontSize = 11.sp
            )
            Slider(
                value = chromaThreshold,
                onValueChange = onChromaThresholdChange,
                valueRange = 0.1f..0.8f,
                colors = SliderDefaults.colors(thumbColor = Color(0xFF00E5FF), activeTrackColor = Color(0xFF00E5FF))
            )
        }
    }
}

@Composable
private fun MotionGraphicsTabContent(
    onSelectPreset: (String) -> Unit
) {
    val presets = listOf(
        Triple("kinetic_title", "Kinetic Title", "Wiggle expression + Bézier spring"),
        Triple("lower_third", "Lower Third", "Broadcast cinematic nameplate"),
        Triple("social_badge", "Social Callout", "Subscribe / Follow banner"),
        Triple("glitch_intro", "Glitch Intro", "Cyberpunk RGB chromatic distortion")
    )

    Column(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = "After Effects JSX Motion Graphics Templates",
            color = Color.White,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold
        )

        Spacer(modifier = Modifier.height(12.dp))

        presets.forEach { (id, title, desc) ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(Color(0xFF161922))
                    .border(0.5.dp, Color(0xFF2C3243), RoundedCornerShape(10.dp))
                    .clickable { onSelectPreset(id) }
                    .padding(14.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(title, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                    Text(desc, color = Color(0xFF8E95A5), fontSize = 11.sp)
                }
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(Color(0xFF7C4DFF).copy(alpha = 0.2f))
                        .padding(horizontal = 10.dp, vertical = 6.dp)
                ) {
                    Text("Add", color = Color(0xFF7C4DFF), fontSize = 12.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
