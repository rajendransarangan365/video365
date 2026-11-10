package com.tharunbirla.librecuts.ui

import android.graphics.SurfaceTexture
import android.view.Surface
import android.view.TextureView
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import com.tharunbirla.librecuts.Video365Engine

@Composable
fun Video365Preview(modifier: Modifier = Modifier) {
    AndroidView(
        modifier = modifier,
        factory = { context ->
            TextureView(context).apply {
                surfaceTextureListener = object : TextureView.SurfaceTextureListener {
                    override fun onSurfaceTextureAvailable(st: SurfaceTexture, width: Int, height: Int) {
                        Video365Engine.initRenderer()
                        Video365Engine.onSurfaceCreated(Surface(st))
                        Video365Engine.onSurfaceChanged(width, height)
                    }

                    override fun onSurfaceTextureSizeChanged(st: SurfaceTexture, width: Int, height: Int) {
                        Video365Engine.onSurfaceChanged(width, height)
                    }

                    override fun onSurfaceTextureDestroyed(st: SurfaceTexture): Boolean {
                        Video365Engine.onSurfaceDestroyed()
                        return true
                    }

                    override fun onSurfaceTextureUpdated(st: SurfaceTexture) {
                        // In a real implementation, the render loop would be driven by a 
                        // Choreographer or a dedicated thread, but we can trigger a render here 
                        // for testing or if the preview is static.
                    }
                }
            }
        }
    )
}
