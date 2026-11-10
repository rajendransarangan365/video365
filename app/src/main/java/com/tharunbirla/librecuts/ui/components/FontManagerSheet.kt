package com.tharunbirla.librecuts.ui.components

import android.graphics.Typeface
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tharunbirla.librecuts.utils.FontItem
import com.tharunbirla.librecuts.utils.FontManager
import com.tharunbirla.librecuts.viewmodels.Video365ViewModel
import java.io.File

data class BuiltInFontPreset(
    val name: String,
    val styleDesc: String,
    val fontFamily: FontFamily,
    val fontWeight: FontWeight = FontWeight.Normal,
    val fontStyle: FontStyle = FontStyle.Normal
)

val builtInFontPresets = listOf(
    BuiltInFontPreset("Montserrat (Modern Bold)", "Clean, modern geometric sans", FontFamily.SansSerif, FontWeight.Bold),
    BuiltInFontPreset("Great Vibes (Cursive)", "Elegant cursive calligraphy script", FontFamily.Cursive, FontWeight.Normal, FontStyle.Italic),
    BuiltInFontPreset("Playfair (Luxury Serif)", "High-contrast editorial serif", FontFamily.Serif, FontWeight.Bold),
    BuiltInFontPreset("Bebas Neue (Condensed)", "Tall impactful header typography", FontFamily.SansSerif, FontWeight.ExtraBold),
    BuiltInFontPreset("Pacifico (Handwritten)", "Casual friendly brush lettering", FontFamily.Cursive, FontWeight.Medium),
    BuiltInFontPreset("Roboto Regular (Standard)", "Neutral balanced neo-grotesque", FontFamily.Default, FontWeight.Normal),
    BuiltInFontPreset("Fira Code (Monospace)", "Retro technical programming mono", FontFamily.Monospace, FontWeight.Medium)
)

val textColors = listOf(
    "#FFFFFF" to Color.White,
    "#00E5FF" to Color(0xFF00E5FF), // Cyan
    "#FFD600" to Color(0xFFFFD600), // Yellow
    "#00E676" to Color(0xFF00E676), // Green
    "#FF4081" to Color(0xFFFF4081), // Pink
    "#FF6D00" to Color(0xFFFF6D00), // Amber
    "#D500F9" to Color(0xFFD500F9), // Purple
    "#000000" to Color.Black
)

/**
 * Mobile-grade Typography & Font Manager for Video365.
 * Allows users to choose built-in typography or install/import ANY custom font file (.ttf / .otf).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FontManagerSheet(
    viewModel: Video365ViewModel,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    var activeTab by remember { mutableIntStateOf(0) } // 0: Built-in, 1: Installed Custom, 2: System Fonts
    
    val activeText by viewModel.activeTextContent.collectAsState()
    val activeFontName by viewModel.activeFontName.collectAsState()
    val activeFontPath by viewModel.activeFontPath.collectAsState()
    val activeTextColor by viewModel.activeTextColor.collectAsState()
    val activeFontSize by viewModel.activeFontSize.collectAsState()

    var customFontsList by remember { mutableStateOf(FontManager.getCustomFonts(context)) }
    var systemFontsList by remember { mutableStateOf<List<FontItem>>(emptyList()) }
    var importStatusMessage by remember { mutableStateOf<String?>(null) }

    fun refreshFonts() {
        customFontsList = FontManager.getCustomFonts(context)
        systemFontsList = FontManager.getAllFonts(context, null).filter { !it.isCustom }
    }

    LaunchedEffect(Unit) {
        refreshFonts()
    }

    // System file picker for ANY .ttf or .otf font file
    val fontPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocument()
    ) { uri: Uri? ->
        if (uri != null) {
            val imported = FontManager.importFontFromUri(context, uri)
            if (imported != null) {
                importStatusMessage = "Installed: ${imported.name}"
                viewModel.selectFont(imported.name, imported.path)
                refreshFonts()
                activeTab = 1 // Switch to Installed tab
            } else {
                importStatusMessage = "Failed to load font file. Please select a valid .ttf or .otf"
            }
        }
    }

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
                        text = "Typography & Fonts",
                        color = Color.White,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Current: $activeFontName",
                        color = Color(0xFF00E5FF),
                        fontSize = 11.sp
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Close", tint = Color.LightGray)
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Text Input Box (Edit title text on the fly)
            OutlinedTextField(
                value = activeText,
                onValueChange = { viewModel.updateTextContent(it) },
                label = { Text("Layer Text Content", color = Color.Gray, fontSize = 11.sp) },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = Color(0xFF141722),
                    unfocusedContainerColor = Color(0xFF141722),
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    focusedBorderColor = Color(0xFF00E5FF),
                    unfocusedBorderColor = Color(0xFF2A3146)
                ),
                singleLine = true
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Install Custom Font CTA Button
            Button(
                onClick = {
                    fontPickerLauncher.launch(
                        arrayOf(
                            "font/*",
                            "font/ttf",
                            "font/otf",
                            "application/x-font-ttf",
                            "application/x-font-otf",
                            "application/octet-stream",
                            "*/*"
                        )
                    )
                },
                modifier = Modifier.fillMaxWidth().height(48.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF7C4DFF))
            ) {
                Icon(Icons.Default.Add, contentDescription = "Install Font", tint = Color.White)
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Install Custom Font (.ttf / .otf)",
                    color = Color.White,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            if (importStatusMessage != null) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = importStatusMessage ?: "",
                    color = Color(0xFF00E676),
                    fontSize = 11.sp
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Color Palette & Size Slider Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Color", color = Color.Gray, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.horizontalScroll(rememberScrollState())
                ) {
                    textColors.forEach { (hex, color) ->
                        val isSelected = activeTextColor.equals(hex, ignoreCase = true)
                        Box(
                            modifier = Modifier
                                .size(28.dp)
                                .clip(CircleShape)
                                .background(color)
                                .border(
                                    width = if (isSelected) 2.dp else 1.dp,
                                    color = if (isSelected) Color(0xFF00E5FF) else Color.DarkGray,
                                    shape = CircleShape
                                )
                                .clickable { viewModel.updateTextColor(hex) },
                            contentAlignment = Alignment.Center
                        ) {
                            if (isSelected) {
                                Icon(
                                    Icons.Default.Check,
                                    contentDescription = null,
                                    tint = if (color == Color.White) Color.Black else Color.White,
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Font Size Slider
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Size: ${activeFontSize.toInt()}sp", color = Color.Gray, fontSize = 11.sp, modifier = Modifier.width(70.dp))
                Slider(
                    value = activeFontSize,
                    onValueChange = { viewModel.updateFontSize(it) },
                    valueRange = 12f..60f,
                    modifier = Modifier.weight(1f),
                    colors = SliderDefaults.colors(
                        thumbColor = Color(0xFF00E5FF),
                        activeTrackColor = Color(0xFF00E5FF),
                        inactiveTrackColor = Color(0xFF232838)
                    )
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Tabs: Presets | Installed Custom | System Fonts
            TabRow(
                selectedTabIndex = activeTab,
                containerColor = Color(0xFF141722),
                contentColor = Color(0xFF00E5FF),
                divider = {}
            ) {
                Tab(
                    selected = activeTab == 0,
                    onClick = { activeTab = 0 },
                    text = { Text("Presets", fontSize = 12.sp) }
                )
                Tab(
                    selected = activeTab == 1,
                    onClick = { activeTab = 1 },
                    text = { Text("Installed (${customFontsList.size})", fontSize = 12.sp) }
                )
                Tab(
                    selected = activeTab == 2,
                    onClick = { activeTab = 2 },
                    text = { Text("System Fonts", fontSize = 12.sp) }
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Font List Content
            Box(modifier = Modifier.fillMaxWidth().height(220.dp)) {
                when (activeTab) {
                    0 -> {
                        // Built-in Font Presets
                        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            items(builtInFontPresets) { fontPreset ->
                                val isSelected = activeFontName == fontPreset.name
                                Card(
                                    colors = CardDefaults.cardColors(
                                        containerColor = if (isSelected) Color(0xFF1B2A38) else Color(0xFF161923)
                                    ),
                                    shape = RoundedCornerShape(10.dp),
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .border(
                                            1.dp,
                                            if (isSelected) Color(0xFF00E5FF) else Color(0xFF242A3D),
                                            RoundedCornerShape(10.dp)
                                        )
                                        .clickable {
                                            viewModel.selectFont(fontPreset.name, null)
                                        }
                                ) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth().padding(12.dp),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Column(modifier = Modifier.weight(1f)) {
                                            Text(
                                                text = activeText.ifBlank { "Sample Typography" },
                                                color = Color.White,
                                                fontSize = 16.sp,
                                                fontFamily = fontPreset.fontFamily,
                                                fontWeight = fontPreset.fontWeight,
                                                fontStyle = fontPreset.fontStyle
                                            )
                                            Spacer(modifier = Modifier.height(2.dp))
                                            Text(
                                                text = fontPreset.name,
                                                color = Color(0xFF8E95A5),
                                                fontSize = 11.sp
                                            )
                                        }
                                        if (isSelected) {
                                            Icon(Icons.Default.Check, contentDescription = "Active", tint = Color(0xFF00E5FF))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    1 -> {
                        // User Installed Custom Fonts (.ttf / .otf)
                        if (customFontsList.isEmpty()) {
                            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(
                                        "No custom fonts installed yet.",
                                        color = Color.Gray,
                                        fontSize = 13.sp
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        "Tap 'Install Custom Font' above to import any .ttf or .otf file.",
                                        color = Color.DarkGray,
                                        fontSize = 11.sp
                                    )
                                }
                            }
                        } else {
                            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                items(customFontsList) { fontItem ->
                                    val isSelected = activeFontPath == fontItem.path
                                    val fontFam = remember(fontItem.path) {
                                        try {
                                            FontFamily(Typeface.createFromFile(fontItem.path))
                                        } catch (_: Exception) {
                                            FontFamily.Default
                                        }
                                    }

                                    Card(
                                        colors = CardDefaults.cardColors(
                                            containerColor = if (isSelected) Color(0xFF1B2A38) else Color(0xFF161923)
                                        ),
                                        shape = RoundedCornerShape(10.dp),
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .border(
                                                1.dp,
                                                if (isSelected) Color(0xFF00E5FF) else Color(0xFF242A3D),
                                                RoundedCornerShape(10.dp)
                                            )
                                            .clickable {
                                                viewModel.selectFont(fontItem.name, fontItem.path)
                                            }
                                    ) {
                                        Row(
                                            modifier = Modifier.fillMaxWidth().padding(12.dp),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Column(modifier = Modifier.weight(1f)) {
                                                Text(
                                                    text = activeText.ifBlank { "Sample Typography" },
                                                    color = Color.White,
                                                    fontSize = 16.sp,
                                                    fontFamily = fontFam
                                                )
                                                Spacer(modifier = Modifier.height(2.dp))
                                                Text(
                                                    text = "${fontItem.name} (Custom Font)",
                                                    color = Color(0xFF00E5FF),
                                                    fontSize = 11.sp
                                                )
                                            }
                                            Row(verticalAlignment = Alignment.CenterVertically) {
                                                if (isSelected) {
                                                    Icon(Icons.Default.Check, contentDescription = "Active", tint = Color(0xFF00E5FF))
                                                    Spacer(modifier = Modifier.width(12.dp))
                                                }
                                                IconButton(
                                                    onClick = {
                                                        FontManager.deleteCustomFont(context, fontItem.path)
                                                        refreshFonts()
                                                    },
                                                    modifier = Modifier.size(28.dp)
                                                ) {
                                                    Icon(Icons.Default.Delete, contentDescription = "Delete", tint = Color.Gray, modifier = Modifier.size(18.dp))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    2 -> {
                        // System Fonts
                        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            items(systemFontsList.take(25)) { fontItem ->
                                val isSelected = activeFontPath == fontItem.path
                                val fontFam = remember(fontItem.path) {
                                    try {
                                        FontFamily(Typeface.createFromFile(fontItem.path))
                                    } catch (_: Exception) {
                                        FontFamily.Default
                                    }
                                }

                                Card(
                                    colors = CardDefaults.cardColors(
                                        containerColor = if (isSelected) Color(0xFF1B2A38) else Color(0xFF161923)
                                    ),
                                    shape = RoundedCornerShape(10.dp),
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clickable {
                                            viewModel.selectFont(fontItem.name, fontItem.path)
                                        }
                                ) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth().padding(10.dp),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Column(modifier = Modifier.weight(1f)) {
                                            Text(
                                                text = fontItem.name,
                                                color = Color.White,
                                                fontSize = 14.sp,
                                                fontFamily = fontFam
                                            )
                                            Text(
                                                text = File(fontItem.path).name,
                                                color = Color.DarkGray,
                                                fontSize = 10.sp
                                            )
                                        }
                                        if (isSelected) {
                                            Icon(Icons.Default.Check, contentDescription = "Active", tint = Color(0xFF00E5FF))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

