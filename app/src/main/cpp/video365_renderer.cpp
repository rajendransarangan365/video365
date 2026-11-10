#include "video365_renderer.h"
#include "shaders.h"
#include <android/log.h>
#include <vector>
#include <stdlib.h>
#include <GLES3/gl32.h>
#include <GLES2/gl2ext.h>

#define LOG_TAG "Video365Renderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

Video365Renderer::Video365Renderer() {
    mRenderGraph = new RenderGraph();
}

Video365Renderer::~Video365Renderer() {
    terminateGL();
    delete mRenderGraph;
}

static GLuint compileShader(GLenum type, const char* source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, nullptr);
    glCompileShader(shader);
    GLint compiled;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char* infoLog = (char*)malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, nullptr, infoLog);
            LOGE("Error compiling shader:\n%s", infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

static GLuint linkProgram(GLuint vert, GLuint frag) {
    GLuint program = glCreateProgram();
    glAttachShader(program, vert);
    glAttachShader(program, frag);
    glLinkProgram(program);
    GLint linked;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char* infoLog = (char*)malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program, infoLen, nullptr, infoLog);
            LOGE("Error linking program:\n%s", infoLog);
            free(infoLog);
        }
        glDeleteProgram(program);
        return 0;
    }
    return program;
}

void Video365Renderer::onSurfaceCreated(ANativeWindow* window) {
    std::lock_guard<std::mutex> lock(mMutex);
    mWindow = window;
    initGL();

    GLuint vShader = compileShader(GL_VERTEX_SHADER, VERTEX_SHADER);

    // Default OES passthrough shader
    const char* FRAGMENT_OES = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;
void main() {
    fragColor = texture(uTexture, vTexCoord);
}
)glsl";
    mProgram = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, FRAGMENT_OES));

    // Dolly Zoom Program (OES)
    mDollyProgram = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, SHADER_DOLLY_ZOOM));

    // Transitions
    mTransitionPrograms["dissolve"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_DISSOLVE));
    mTransitionPrograms["whip_pan"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_WHIP_PAN));
    mTransitionPrograms["glitch"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_GLITCH));
    mTransitionPrograms["zoom"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_ZOOM));
    mTransitionPrograms["film_burn"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_FILM_BURN));
    mTransitionPrograms["radial_blur"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_RADIAL_BLUR));
    mTransitionPrograms["swirl"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_SWIRL));
    mTransitionPrograms["wipe"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_WIPE));
    mTransitionPrograms["wave"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_WAVE));
    mTransitionPrograms["doorway"] = linkProgram(vShader, compileShader(GL_FRAGMENT_SHADER, TRANSITION_DOORWAY));

    // Geometry
    float vertices[] = {
        -1.0f,  1.0f, 0.0f,  0.0f, 0.0f,
        -1.0f, -1.0f, 0.0f,  0.0f, 1.0f,
         1.0f, -1.0f, 0.0f,  1.0f, 1.0f,
         1.0f,  1.0f, 0.0f,  1.0f, 0.0f
    };

    glGenBuffers(1, &mVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    createExternalTexture();

    LOGI("NDK Renderer: Resources Initialized");
}

void Video365Renderer::createExternalTexture() {
    glGenTextures(1, &mExternalTextureId);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, mExternalTextureId);
    glTexParameterf(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

void Video365Renderer::onSurfaceChanged(int width, int height) {
    std::lock_guard<std::mutex> lock(mMutex);
    mWidth = width;
    mHeight = height;
    if (mContext != EGL_NO_CONTEXT) {
        glViewport(0, 0, mWidth, mHeight);
    }
}

void Video365Renderer::onSurfaceDestroyed() {
    std::lock_guard<std::mutex> lock(mMutex);
    terminateGL();
    mWindow = nullptr;
}

bool Video365Renderer::makeCurrent() {
    std::lock_guard<std::mutex> lock(mMutex);
    if (mDisplay != EGL_NO_DISPLAY && mSurface != EGL_NO_SURFACE && mContext != EGL_NO_CONTEXT) {
        return eglMakeCurrent(mDisplay, mSurface, mSurface, mContext) == EGL_TRUE;
    }
    return false;
}

void Video365Renderer::render(long timeMs) {
    std::lock_guard<std::mutex> lock(mMutex);
    if (mDisplay == EGL_NO_DISPLAY || mSurface == EGL_NO_SURFACE || mContext == EGL_NO_CONTEXT) return;

    eglMakeCurrent(mDisplay, mSurface, mSurface, mContext);
    glViewport(0, 0, mWidth, mHeight);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    // AI Smoothing Logic (Exponential Moving Average)
    mCurrentZoom = mCurrentZoom * 0.92f + mDollyZoom * 0.08f;

    // Use Render Graph to draw multiple layers (Video, Overlays, AI effects)
    if (mRenderGraph) {
        mRenderGraph->render(timeMs, mExternalTextureId, mWidth, mHeight,
                           mProgram, mDollyProgram, mCurrentZoom, mFaceCenterX, mFaceCenterY, mVBO);
    }

    eglSwapBuffers(mDisplay, mSurface);
}

void Video365Renderer::setFaceCenter(float x, float y) {
    std::lock_guard<std::mutex> lock(mMutex);
    mFaceCenterX = x;
    mFaceCenterY = y;
}

void Video365Renderer::setDollyZoom(float zoom) {
    std::lock_guard<std::mutex> lock(mMutex);
    mDollyZoom = zoom;
}

void Video365Renderer::setTransition(const std::string& type, float progress) {
    std::lock_guard<std::mutex> lock(mMutex);
    mCurrentTransition = type;
    mTransitionProgress = progress;
}

void Video365Renderer::initGL() {
    mDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    eglInitialize(mDisplay, nullptr, nullptr);
    const EGLint attribs[] = {
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_BLUE_SIZE, 8, EGL_GREEN_SIZE, 8, EGL_RED_SIZE, 8,
        EGL_DEPTH_SIZE, 24, EGL_NONE
    };
    EGLConfig config;
    EGLint numConfigs;
    eglChooseConfig(mDisplay, attribs, &config, 1, &numConfigs);
    mSurface = eglCreateWindowSurface(mDisplay, config, mWindow, nullptr);
    const EGLint contextAttribs[] = { EGL_CONTEXT_CLIENT_VERSION, 3, EGL_NONE };
    mContext = eglCreateContext(mDisplay, config, EGL_NO_CONTEXT, contextAttribs);
    eglMakeCurrent(mDisplay, mSurface, mSurface, mContext);
}

void Video365Renderer::terminateGL() {
    if (mDisplay != EGL_NO_DISPLAY) {
        eglMakeCurrent(mDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (mContext != EGL_NO_CONTEXT) eglDestroyContext(mDisplay, mContext);
        if (mSurface != EGL_NO_SURFACE) eglDestroySurface(mDisplay, mSurface);
        eglTerminate(mDisplay);
    }
    mDisplay = EGL_NO_DISPLAY; mSurface = EGL_NO_SURFACE; mContext = EGL_NO_CONTEXT;
    mProgram = 0; mDollyProgram = 0; mVBO = 0; mTransitionPrograms.clear();
    if (mExternalTextureId != 0) {
        glDeleteTextures(1, &mExternalTextureId);
        mExternalTextureId = 0;
    }
}
