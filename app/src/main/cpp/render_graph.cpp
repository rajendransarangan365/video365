#include "render_graph.h"
#include <GLES3/gl32.h>
#include <GLES2/gl2ext.h>
#include <android/log.h>

#define LOG_TAG "Video365RenderGraph"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

RenderGraph::RenderGraph() {}
RenderGraph::~RenderGraph() {}

void RenderGraph::updateLayers(const std::string& json) {
    std::lock_guard<std::mutex> lock(mRenderMutex);
    // TODO: In Phase 2, parse real JSON from Video365Project v2.0
    // For now, we maintain a hardcoded set of layers for the demo.
    if (mLayers.empty()) {
        RenderLayer videoLayer;
        videoLayer.id = "lyr_base_video";
        videoLayer.type = LayerType::VIDEO_OES;
        videoLayer.assetIndex = 0;
        mLayers.push_back(videoLayer);
        mLayerMap[videoLayer.id] = &mLayers.back();
    }
}

void RenderGraph::resolveHierarchy() {
    for (auto& layer : mLayers) {
        glm::mat4 model = glm::mat4(1.0f);
        // Translation -> Rotation -> Scale (AE Order)
        model = glm::translate(model, layer.position);
        model = glm::rotate(model, glm::radians(layer.rotation), glm::vec3(0, 0, 1));
        model = glm::scale(model, layer.scale);

        if (!layer.parentId.empty() && mLayerMap.count(layer.parentId)) {
            layer.modelMatrix = mLayerMap[layer.parentId]->modelMatrix * model;
        } else {
            layer.modelMatrix = model;
        }
    }
}

void RenderGraph::render(long timeMs, GLuint oesTextureId, int width, int height,
                        GLuint baseProgram, GLuint dollyProgram,
                        float currentZoom, float faceX, float faceY, GLuint vbo) {
    std::lock_guard<std::mutex> lock(mRenderMutex);

    resolveHierarchy();

    // Quad vertices are in NDC [-1, 1], so base projection is identity
    glm::mat4 viewProj = glm::mat4(1.0f);

    for (auto& layer : mLayers) {
        renderLayer(layer, viewProj, oesTextureId, baseProgram, dollyProgram, currentZoom, faceX, faceY, vbo);
    }
}

void RenderGraph::renderLayer(RenderLayer& layer, const glm::mat4& viewProj,
                             GLuint oesTextureId, GLuint baseProgram,
                             GLuint dollyProgram, float zoom, float fx, float fy, GLuint vbo) {
    GLuint program = baseProgram;

    // Switch to Dolly Zoom shader for the primary video layer if AI is active
    if (layer.type == LayerType::VIDEO_OES && zoom > 1.01f) {
        program = dollyProgram;
    }

    glUseProgram(program);

    // Set MVP Matrix
    glm::mat4 mvp = viewProj * layer.modelMatrix;
    GLint mvpLoc = glGetUniformLocation(program, "uMVP");
    if (mvpLoc != -1) {
        glUniformMatrix4fv(mvpLoc, 1, GL_FALSE, &mvp[0][0]);
    }

    // Set Opacity
    GLint alphaLoc = glGetUniformLocation(program, "uOpacity");
    if (alphaLoc != -1) {
        glUniform1f(alphaLoc, layer.opacity);
    }

    if (layer.type == LayerType::VIDEO_OES) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_EXTERNAL_OES, oesTextureId);
        glUniform1i(glGetUniformLocation(program, "uTexture"), 0);

        if (program == dollyProgram) {
            glUniform2f(glGetUniformLocation(program, "uFaceCenter"), fx, fy);
            glUniform1f(glGetUniformLocation(program, "uZoom"), zoom);
        }
    } else {
        // Standard Image/Shape layer rendering
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, layer.textureId);
        glUniform1i(glGetUniformLocation(program, "uTexture"), 0);
    }

    // Bind VBO and enable vertex attributes
    if (vbo != 0) {
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    }

    // Drawing call happens here
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

    if (vbo != 0) {
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
}
