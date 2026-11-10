package com.tharunbirla.librecuts.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog

data class CommandItem(val name: String, val category: String, val action: () -> Unit)

/**
 * Mobile equivalent of AE's Ctrl+Enter / OpenCut Command Palette.
 * A fuzzy-search modal for applying effects, running scripts, and commands.
 */
@Composable
fun CommandBar(
    onDismiss: () -> Unit,
    onOpenScripting: () -> Unit = {},
    onOpenFontManager: () -> Unit = {}
) {
    var query by remember { mutableStateOf("") }

    val commandList = listOf(
        CommandItem("Open Typography & Font Manager", "Typography") { 
            onOpenFontManager() 
        },
        CommandItem("Install Custom Font (.ttf / .otf)", "Typography") { 
            onOpenFontManager() 
        },
        CommandItem("Open Scripting & REPL Console", "OpenCut Scripting") { 
            onOpenScripting() 
        },
        CommandItem("Smart Silence Remover (Auto-Cut)", "OpenCut AI") { 
            onOpenScripting() 
        },
        CommandItem("Apply Glitch RGB Effect", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("glitch", 0.5f) 
        },
        CommandItem("Apply Whip Pan Blur", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("whip_pan", 0.5f) 
        },
        CommandItem("Apply Swirl Vortex", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("swirl", 0.5f) 
        },
        CommandItem("Apply Water Wave Ripple", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("wave", 0.5f) 
        },
        CommandItem("Apply Doorway 3D", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("doorway", 0.5f) 
        },
        CommandItem("Apply Linear Wipe", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("wipe", 0.5f) 
        },
        CommandItem("Apply Radial Blur", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("radial_blur", 0.5f) 
        },
        CommandItem("Apply Film Burn", "Transitions") { 
            com.tharunbirla.librecuts.Video365Engine.setTransition("film_burn", 0.5f) 
        },
        CommandItem("Dolly Zoom (Face Track)", "AI") { 
            com.tharunbirla.librecuts.Video365Engine.setDollyZoom(2.0f) 
        },
        CommandItem("Reset Zoom & Effects", "Effects") { 
            com.tharunbirla.librecuts.Video365Engine.setDollyZoom(1.0f)
            com.tharunbirla.librecuts.Video365Engine.setTransition("", 0.0f) 
        },
        CommandItem("Eval Wiggle(3, 25)", "Expressions") { 
            val w = com.tharunbirla.librecuts.Video365Engine.evaluateExpressionFloat("wiggle(3.0, 25.0)", 1.5f, 540f)
            android.util.Log.i("CommandBar", "Evaluated wiggle: $w")
        },
        CommandItem("Add Kinetic Title (JSX)", "Motion Graphics") { /* JSX Preset */ },
        CommandItem("Add Lower Third (JSX)", "Motion Graphics") { /* JSX Preset */ }
    )

    val filteredCommands = commandList.filter { 
        it.name.contains(query, ignoreCase = true) || it.category.contains(query, ignoreCase = true)
    }

    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 420.dp),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFF161922))
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                TextField(
                    value = query,
                    onValueChange = { query = it },
                    placeholder = { Text("Search Effects, Fonts, or Commands...") },
                    modifier = Modifier.fillMaxWidth(),
                    leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = Color(0xFF00E5FF)) },
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color(0xFF222736),
                        unfocusedContainerColor = Color(0xFF222736),
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                LazyColumn {
                    items(filteredCommands) { command ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { 
                                    command.action()
                                    onDismiss()
                                }
                                .padding(vertical = 12.dp, horizontal = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(command.name, color = Color.White, modifier = Modifier.weight(1f))
                            Text(
                                text = command.category,
                                color = Color(0xFF00E5FF),
                                style = MaterialTheme.typography.labelSmall
                            )
                        }
                    }
                }
            }
        }
    }
}
