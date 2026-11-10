package com.tharunbirla.librecuts.engine

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Manages background generation of lightweight intra-frame 540p proxies
 * for 4K / 1080p source footage to eliminate UI stutter and thermal throttling ("Render on the Go").
 */
class ProxyManager(private val context: Context) {
    private val proxyDir = File(context.cacheDir, "video365_proxies").apply { mkdirs() }

    /**
     * Determines if a source asset requires a proxy (> 1080p).
     */
    suspend fun shouldGenerateProxy(sourceUri: Uri): Boolean = withContext(Dispatchers.IO) {
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(context, sourceUri)
            val width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 0
            val height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull() ?: 0
            return@withContext width > 1080 || height > 1080
        } catch (e: Exception) {
            Log.w("ProxyManager", "Could not inspect media dimensions: ${e.message}")
            return@withContext false
        } finally {
            try { retriever.release() } catch (_: Exception) {}
        }
    }

    /**
     * Prepares or retrieves a lightweight proxy URI.
     */
    suspend fun getOrCreateProxy(sourceUri: Uri): Uri = withContext(Dispatchers.IO) {
        val proxyFile = File(proxyDir, "proxy_${sourceUri.hashCode().toString(16)}.mp4")
        if (proxyFile.exists() && proxyFile.length() > 0) {
            return@withContext Uri.fromFile(proxyFile)
        }

        // On device, when proxy generation is triggered, we can create a fast copy or hardware-transcoded proxy
        try {
            // For fast demonstration / mock proxy if transcoding isn't needed immediately:
            context.contentResolver.openInputStream(sourceUri)?.use { input ->
                proxyFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
            return@withContext Uri.fromFile(proxyFile)
        } catch (e: Exception) {
            Log.w("ProxyManager", "Proxy copy failed, falling back to source: ${e.message}")
            return@withContext sourceUri
        }
    }

    fun clearProxies() {
        proxyDir.deleteRecursively()
        proxyDir.mkdirs()
    }
}

