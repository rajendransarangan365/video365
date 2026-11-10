#ifndef VIDEO365_RENDER_GRAPH_H
#define VIDEO365_RENDER_GRAPH_H

#include <vector>
#include <string>
#include <map>
#include <mutex>
#include <GLES3/gl32.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

enum class LayerType {
    VIDEO_OES,
    IMAGE,
    TEXT,
    SHAPE,
    ADJUSTMENT
};

struct RenderLayer {
    std::string id;
    LayerType type;
    int assetIndex;

    glm::vec3 position = glm::vec3(0.0f);
    glm::vec3 scale = glm::vec3(1.0f);
    float rotation = 0.0f;
    float opacity = 1.0f;

    std::string blendMode = "normal";
    std::string parentId = "";

    // Cached computed matrix
    glm::mat4 modelMatrix = glm::mat4(1.0f);

    GLuint textureId = 0;
};

class RenderGraph {
public:
    RenderGraph();
    ~RenderGraph();

    void updateLayers(const std::string& json);
    void resolveHierarchy();
    void render(long timeMs, GLuint oesTextureId, int width, int height,
                GLuint baseProgram, GLuint dollyProgram,
                float currentZoom, float faceX, float faceY, GLuint vbo = 0);

private:
    std::vector<RenderLayer> mLayers;
    std::map<std::string, RenderLayer*> mLayerMap;
    std::mutex mRenderMutex;

    void renderLayer(RenderLayer& layer, const glm::mat4& viewProj,
                     GLuint oesTextureId, GLuint baseProgram,
                     GLuint dollyProgram, float zoom, float fx, float fy, GLuint vbo = 0);
};

#endif //VIDEO365_RENDER_GRAPH_H
