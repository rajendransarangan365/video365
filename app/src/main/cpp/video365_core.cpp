#include <jni.h>
#include <string>
#include <android/log.h>
#include <android/native_window_jni.h>
#include "video365_renderer.h"
#include "expression_engine.h"

#define LOG_TAG "Video365Core"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

static Video365Renderer* gRenderer = nullptr;
static ExpressionEngine gExpressionEngine;

extern "C" JNIEXPORT jstring JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_getNativeVersion(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Video365 Core v2.0.0 (GLES 3.2)";
    return env->NewStringUTF(hello.c_str());
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_initRenderer(
        JNIEnv* env,
        jobject /* this */) {
    if (!gRenderer) {
        gRenderer = new Video365Renderer();
        LOGI("Video365 Renderer Initialized");
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_onSurfaceCreated(
        JNIEnv* env,
        jobject /* this */,
        jobject surface) {
    if (gRenderer && surface) {
        ANativeWindow* window = ANativeWindow_fromSurface(env, surface);
        gRenderer->onSurfaceCreated(window);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_onSurfaceChanged(
        JNIEnv* env,
        jobject /* this */,
        jint width,
        jint height) {
    if (gRenderer) {
        gRenderer->onSurfaceChanged(width, height);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_onSurfaceDestroyed(
        JNIEnv* env,
        jobject /* this */) {
    if (gRenderer) {
        gRenderer->onSurfaceDestroyed();
    }
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_makeCurrent(
        JNIEnv* env,
        jobject /* this */) {
    if (gRenderer) {
        return gRenderer->makeCurrent() ? JNI_TRUE : JNI_FALSE;
    }
    return JNI_FALSE;
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_renderFrame(
        JNIEnv* env,
        jobject /* this */,
        jlong timeMs) {
    if (gRenderer) {
        gRenderer->render(timeMs);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_nativeUpdateProjectState(
        JNIEnv* env,
        jobject /* this */,
        jstring projectJson) {
    const char* json = env->GetStringUTFChars(projectJson, nullptr);
    // LOGI("Updating Project State: %s", json);
    // TODO: Parse JSON using a C++ JSON library and update Render Graph
    env->ReleaseStringUTFChars(projectJson, json);
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_startTracking(
        JNIEnv* env,
        jobject /* this */,
        jfloat x,
        jfloat y) {
    if (gRenderer) {
        gRenderer->setFaceCenter(x, y);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_setDollyZoom(
        JNIEnv* env,
        jobject /* this */,
        jfloat zoom) {
    if (gRenderer) {
        gRenderer->setDollyZoom(zoom);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_setFaceCenter(
        JNIEnv* env,
        jobject /* this */,
        jfloat x,
        jfloat y) {
    if (gRenderer) {
        gRenderer->setFaceCenter(x, y);
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_getExternalTextureId(
        JNIEnv* env,
        jobject /* this */) {
    if (gRenderer) {
        return gRenderer->getExternalTextureId();
    }
    return 0;
}

extern "C" JNIEXPORT void JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_setTransition(
        JNIEnv* env,
        jobject /* this */,
        jstring type,
        jfloat progress) {
    if (gRenderer) {
        const char* typeStr = env->GetStringUTFChars(type, nullptr);
        gRenderer->setTransition(typeStr, progress);
        env->ReleaseStringUTFChars(type, typeStr);
    }
}

extern "C" JNIEXPORT jfloat JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_evaluateExpressionFloat(
        JNIEnv* env,
        jobject /* this */,
        jstring expr,
        jfloat time,
        jfloat currentValue) {
    const char* exprStr = env->GetStringUTFChars(expr, nullptr);
    float result = gExpressionEngine.evaluateFloat(exprStr, time, currentValue);
    env->ReleaseStringUTFChars(expr, exprStr);
    return result;
}

extern "C" JNIEXPORT jfloatArray JNICALL
Java_com_tharunbirla_librecuts_Video365Engine_evaluateExpressionVector(
        JNIEnv* env,
        jobject /* this */,
        jstring expr,
        jfloat time,
        jfloatArray currentValues) {
    const char* exprStr = env->GetStringUTFChars(expr, nullptr);
    jsize len = env->GetArrayLength(currentValues);
    jfloat* body = env->GetFloatArrayElements(currentValues, 0);

    std::vector<float> inVec(body, body + len);
    std::vector<float> outVec = gExpressionEngine.evaluateVector(exprStr, time, inVec);

    jfloatArray result = env->NewFloatArray(outVec.size());
    env->SetFloatArrayRegion(result, 0, outVec.size(), outVec.data());

    env->ReleaseFloatArrayElements(currentValues, body, JNI_ABORT);
    env->ReleaseStringUTFChars(expr, exprStr);
    return result;
}
