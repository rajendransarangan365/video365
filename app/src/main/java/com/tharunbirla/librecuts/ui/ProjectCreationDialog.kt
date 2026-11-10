package com.tharunbirla.librecuts.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

data class AspectRatioOption(
    val label: String,
    val ratio: String,
    val description: String
)

val aspectRatioOptions = listOf(
    AspectRatioOption("Vertical", "9:16", "TikTok, Reels, Shorts"),
    AspectRatioOption("Horizontal", "16:9", "YouTube, Cinema"),
    AspectRatioOption("Square", "1:1", "Instagram Post"),
    AspectRatioOption("Portrait", "4:5", "Social Media Feed")
)

@Composable
fun ProjectCreationDialog(
    onDismiss: () -> Unit,
    onConfirm: (AspectRatioOption) -> Unit
) {
    var selectedOption by remember { mutableStateOf(aspectRatioOptions[0]) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("New Video365 Project", fontWeight = FontWeight.Bold) },
        text = {
            Column {
                Text("Select Canvas Aspect Ratio", fontSize = 14.sp, color = Color.Gray)
                Spacer(modifier = Modifier.height(16.dp))
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.height(200.dp)
                ) {
                    items(aspectRatioOptions) { option ->
                        Card(
                            colors = CardDefaults.cardColors(
                                containerColor = if (selectedOption == option) 
                                    MaterialTheme.colorScheme.primaryContainer 
                                else MaterialTheme.colorScheme.surfaceVariant
                            ),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { selectedOption = option }
                        ) {
                            Column(
                                modifier = Modifier.padding(12.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text(option.ratio, fontWeight = FontWeight.Bold)
                                Text(option.label, fontSize = 12.sp)
                            }
                        }
                    }
                }
            }
        },
        confirmButton = {
            Button(onClick = { onConfirm(selectedOption) }) {
                Text("Create Project")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
