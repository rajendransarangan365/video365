package com.tharunbirla.librecuts

import android.view.Surface
import com.tharunbirla.librecuts.models.v2.Video365Project
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/**
 * High-level bridge to the C++ Render Graph and AI Engine.
 * Manages JNI lifecycle and state synchronization.
 */
object Video365Engine {
    init {
        System.loadLibrary("video365_core")
    }

    /** Returns the C++ engine version and GLES capability. */
    external fun getNativeVersion(): String

    /** Initializes the OpenGL ES 3.2 renderer. */
    external fun initRenderer()

    /** 
     * Passes the serialized project state to the native Render Graph.
     * Called on every state change to rebuild the DAG if necessary.
     */
    fun updateProjectState(project: Video365Project) {
        val json = Json.encodeToString(project)
        nativeUpdateProjectState(json)
    }

    private external fun nativeUpdateProjectState(projectJson: String)

    /** Connects a Surface (from TextureView/Compose) to the NDK renderer. */
    external fun onSurfaceCreated(surface: Surface)
    
    external fun onSurfaceChanged(width: Int, height: Int)
    
    external fun onSurfaceDestroyed()

    /** Binds the EGLContext to the current thread. */
    external fun makeCurrent(): Boolean

    /** Triggers a frame render for a specific timestamp. */
    external fun renderFrame(timeMs: Long)

    /** AI: Start face/object tracking on the current frame. */
    external fun startTracking(x: Float, y: Float)
    
    /** AI: Update Dolly Zoom level. */
    external fun setDollyZoom(zoom: Float)

    /** AI: Update face center. */
    external fun setFaceCenter(x: Float, y: Float)

    /** Returns the ID of the OES texture created in NDK for video input. */
    external fun getExternalTextureId(): Int

    /** Sets a transition effect. */
    external fun setTransition(type: String, progress: Float)

    /** Evaluates an AE math expression (e.g. wiggle, sin, linear) for a scalar float. */
    external fun evaluateExpressionFloat(expr: String, time: Float, currentValue: Float): Float

    /** Evaluates an AE math expression (e.g. wiggle) for a vector (e.g. [x, y, z] position). */
    external fun evaluateExpressionVector(expr: String, time: Float, currentValues: FloatArray): FloatArray
}
