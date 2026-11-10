package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.engine.Video365EditorApi
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel

/**
 * OpenCut-inspired Scripting & REPL Console Sheet.
 * Enables live execution of ExtendScript / JSX scripts and Model Context Protocol (MCP) commands.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScriptingConsoleSheet(
    viewModel: Video365ViewModel,
    onDismiss: () -> Unit
) {
    val editorApi = remember { Video365EditorApi(viewModel) }
    var scriptInput by remember {
        mutableStateOf("// OpenCut Scripting Engine\napp.project.activeSequence.splitAtPlayhead();\nvideo365.applyTransition('glitch', 0.5);")
    }
    var consoleLogs by remember {
        mutableStateOf("Video365 Scripting & MCP Console ready.\nEnter JSX script or choose a preset below.\n")
    }

    val presetScripts = listOf(
        "Auto-Cut Silence" to "video365.autoRemoveSilence();\n// Scans audio waveforms and ripples silent pauses",
        "Kinetic Title + Wiggle" to "app.project.addTitle('VIDEO365 ULTRA');\ncomp.layer('title').position.expression = 'wiggle(3.0, 25.0)';",
        "Cinematic Lumetri Grade" to "video365.gradeLumetri({\n  exposure: 0.25,\n  contrast: 1.15,\n  saturation: 1.2,\n  vignette: 0.5\n});",
        "RGB Glitch Transition" to "video365.applyTransition('glitch', 0.65);",
        "Doorway 3D Transition" to "video365.applyTransition('doorway', 0.5);",
        "Inspect Project (MCP)" to "video365.getProjectState();"
    )

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = Color(0xFF0F1118),
        dragHandle = { BottomSheetDefaults.DragHandle(color = Color(0xFF33384A)) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Scripting & MCP Console",
                        color = Color.White,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "OpenCut Scripting & Model Context Protocol Bridge",
                        color = Color(0xFF00E5FF),
                        fontSize = 11.sp
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Close", tint = Color.LightGray)
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Presets Horizontal Row
            Text("Presets & AI Actions", color = Color.Gray, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
            Spacer(modifier = Modifier.height(6.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                presetScripts.take(3).forEach { (label, code) ->
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color(0xFF1B2030))
                            .border(1.dp, Color(0xFF2C3247), RoundedCornerShape(8.dp))
                            .clickable { scriptInput = code }
                            .padding(8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = label,
                            color = Color(0xFF80D8FF),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium,
                            maxLines = 1
                        )
                    }
                }
            }
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 10.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                presetScripts.drop(3).take(3).forEach { (label, code) ->
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color(0xFF1B2030))
                            .border(1.dp, Color(0xFF2C3247), RoundedCornerShape(8.dp))
                            .clickable { scriptInput = code }
                            .padding(8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = label,
                            color = Color(0xFFB388FF),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium,
                            maxLines = 1
                        )
                    }
                }
            }

            // Script Editor Box
            Text("JSX / ExtendScript Editor", color = Color.Gray, fontSize = 11.sp)
            Spacer(modifier = Modifier.height(4.dp))
            OutlinedTextField(
                value = scriptInput,
                onValueChange = { scriptInput = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(110.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color(0xFF141722),
                    unfocusedContainerColor = Color(0xFF141722),
                    focusedTextColor = Color(0xFF00E5FF),
                    unfocusedTextColor = Color(0xFF00E5FF),
                    focusedBorderColor = Color(0xFF00E5FF),
                    unfocusedBorderColor = Color(0xFF2A3146)
                ),
                textStyle = androidx.compose.ui.text.TextStyle(
                    fontFamily = FontFamily.Monospace,
                    fontSize = 11.sp
                )
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Action Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Button(
                    onClick = {
                        val result = if (scriptInput.contains("getProjectState")) {
                            editorApi.handleMcpToolCall("video365_get_project_state", "")
                        } else if (scriptInput.contains("autoRemoveSilence")) {
                            editorApi.handleMcpToolCall("video365_auto_remove_silence", "")
                        } else {
                            val res = editorApi.executeScript(scriptInput)
                            if (res.isSuccess) res.output else "Error: ${res.error}"
                        }
                        consoleLogs += "\n> Run: ${scriptInput.lines().firstOrNull()}\n$result\n"
                    },
                    modifier = Modifier.weight(1f),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00E5FF)),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Icon(Icons.Default.PlayArrow, contentDescription = "Run", tint = Color.Black)
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Execute Script", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }

                OutlinedButton(
                    onClick = { consoleLogs = "Console cleared.\n" },
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.LightGray),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Icon(Icons.Default.Refresh, contentDescription = "Clear", modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Clear", fontSize = 12.sp)
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Output Terminal Console
            Text("Console Output (REPL Log)", color = Color.Gray, fontSize = 11.sp)
            Spacer(modifier = Modifier.height(4.dp))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(Color(0xFF0A0B10))
                    .border(1.dp, Color(0xFF1E2333), RoundedCornerShape(8.dp))
                    .padding(8.dp)
                    .verticalScroll(rememberScrollState())
            ) {
                Text(
                    text = consoleLogs,
                    color = Color(0xFF76FF03),
                    fontSize = 10.sp,
                    fontFamily = FontFamily.Monospace,
                    lineHeight = 14.sp
                )
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

