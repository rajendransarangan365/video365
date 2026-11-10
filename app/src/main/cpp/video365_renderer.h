#ifndef VIDEO365_RENDERER_H
#define VIDEO365_RENDERER_H

#include <GLES3/gl32.h>
#include <EGL/egl.h>
#include <android/native_window.h>
#include <mutex>
#include <map>
#include <string>
#include <vector>
#include "expression_engine.h"
#include "render_graph.h"

struct LayerState {
    std::string id;
    float posX = 0.5f;
    float posY = 0.5f;
    float scale = 1.0f;
    float opacity = 1.0f;
    std::string expression;
};

class Video365Renderer {
public:
    Video365Renderer();
    ~Video365Renderer();

    void onSurfaceCreated(ANativeWindow* window);
    void onSurfaceChanged(int width, int height);
    void onSurfaceDestroyed();
    void render(long timeMs);
    bool makeCurrent();

    // AI & Tracking Updates
    void setFaceCenter(float x, float y);
    void setDollyZoom(float zoom);

    // Transition Updates
    void setTransition(const std::string& type, float progress);

    // Texture Management
    GLuint getExternalTextureId() { return mExternalTextureId; }

private:
    void initGL();
    void terminateGL();
    void createExternalTexture();
    void drawLayer(const LayerState& layer, long timeMs);

    ANativeWindow* mWindow = nullptr;
    EGLDisplay mDisplay = EGL_NO_DISPLAY;
    EGLSurface mSurface = EGL_NO_SURFACE;
    EGLContext mContext = EGL_NO_CONTEXT;

    int mWidth = 0;
    int mHeight = 0;

    std::mutex mMutex;

    GLuint mProgram = 0;
    GLuint mDollyProgram = 0;
    GLuint mVBO = 0;
    GLuint mExternalTextureId = 0;

    std::map<std::string, GLuint> mTransitionPrograms;

    ExpressionEngine mExpressionEngine;
    RenderGraph* mRenderGraph = nullptr;

    // Dolly Zoom State
    float mFaceCenterX = 0.5f;
    float mFaceCenterY = 0.5f;
    float mDollyZoom = 1.0f;
    float mCurrentZoom = 1.0f;

    // Transition State
    std::string mCurrentTransition = "none";
    float mTransitionProgress = 0.0f;

    // Demo layers for Phase 1
    std::vector<LayerState> mLayers;
};

#endif //VIDEO365_RENDERER_H
