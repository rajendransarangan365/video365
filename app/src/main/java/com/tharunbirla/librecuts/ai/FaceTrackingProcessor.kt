package com.tharunbirla.librecuts.ai

import android.content.Context
import android.graphics.Bitmap
import android.graphics.RectF
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarker
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarkerResult
import com.tharunbirla.librecuts.Video365Engine
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Handles on-device face detection and landmarking using MediaPipe.
 * Feeds coordinates and zoom factors to the Video365Engine for real-time dolly effects.
 */
class FaceTrackingProcessor(
    private val context: Context,
    private val onResults: (FaceLandmarkerResult) -> Unit
) {
    private var faceLandmarker: FaceLandmarker? = null
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    
    // Target face size in the frame (e.g., 30% of height)
    private val targetFaceHeightRatio = 0.35f

    init {
        setupFaceLandmarker()
    }

    private fun setupFaceLandmarker() {
        try {
            val baseOptions = com.google.mediapipe.tasks.core.BaseOptions.builder()
                .setModelAssetPath("face_landmarker.task")
                .build()

            val options = FaceLandmarker.FaceLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.IMAGE)
                .setNumFaces(1)
                .setMinFaceDetectionConfidence(0.5f)
                .setMinFacePresenceConfidence(0.5f)
                .setMinTrackingConfidence(0.5f)
                .build()

            faceLandmarker = FaceLandmarker.createFromOptions(context, options)
        } catch (t: Throwable) {
            android.util.Log.w("FaceTrackingProcessor", "FaceLandmarker initialization skipped or unavailable: ${t.message}")
        }
    }

    fun detectFace(bitmap: Bitmap) {
        executor.execute {
            try {
                val mpImage = com.google.mediapipe.framework.image.BitmapImageBuilder(bitmap).build()
                val result = faceLandmarker?.detect(mpImage)
                result?.let {
                    processResult(it)
                    onResults(it)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun processResult(result: FaceLandmarkerResult) {
        if (result.faceLandmarks().isNotEmpty()) {
            val landmarks = result.faceLandmarks()[0]
            
            // 1. Calculate face center
            val faceCenter = calculateFaceCenter(landmarks)
            
            // 2. Calculate face height to determine zoom for Dolly effect
            val faceBounds = calculateFaceBounds(landmarks)
            val currentHeight = faceBounds.height()
            
            // Dolly Zoom calculation: Zoom = TargetHeight / CurrentHeight
            // If the face is far (small height), zoom in.
            val calculatedZoom = (targetFaceHeightRatio / currentHeight).coerceIn(1.0f, 4.0f)
            
            // Send to NDK
            Video365Engine.startTracking(faceCenter.x(), faceCenter.y())
            Video365Engine.setDollyZoom(calculatedZoom)
        } else {
            // Reset if no face found or keep last state? For now, slow reset
            Video365Engine.setDollyZoom(1.0f)
        }
    }

    private fun calculateFaceCenter(landmarks: List<NormalizedLandmark>): NormalizedLandmark {
        var sumX = 0f
        var sumY = 0f
        for (l in landmarks) {
            sumX += l.x()
            sumY += l.y()
        }
        return NormalizedLandmark.create(sumX / landmarks.size, sumY / landmarks.size, 0f)
    }
    
    private fun calculateFaceBounds(landmarks: List<NormalizedLandmark>): RectF {
        var minX = 1f; var maxX = 0f
        var minY = 1f; var maxY = 0f
        for (l in landmarks) {
            if (l.x() < minX) minX = l.x()
            if (l.x() > maxX) maxX = l.x()
            if (l.y() < minY) minY = l.y()
            if (l.y() > maxY) maxY = l.y()
        }
        return RectF(minX, minY, maxX, maxY)
    }

    fun close() {
        faceLandmarker?.close()
        executor.shutdown()
    }
}
