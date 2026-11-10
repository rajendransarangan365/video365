#ifndef GLM_GLM_HPP
#define GLM_GLM_HPP

#include <cmath>
#include <cstring>

namespace glm {

struct vec2 {
    float x, y;
    vec2() : x(0), y(0) {}
    vec2(float val) : x(val), y(val) {}
    vec2(float _x, float _y) : x(_x), y(_y) {}
};

struct vec3 {
    float x, y, z;
    vec3() : x(0), y(0), z(0) {}
    vec3(float val) : x(val), y(val), z(val) {}
    vec3(float _x, float _y, float _z) : x(_x), y(_y), z(_z) {}
};

struct vec4 {
    float x, y, z, w;
    vec4() : x(0), y(0), z(0), w(1) {}
    vec4(float val) : x(val), y(val), z(val), w(val) {}
    vec4(float _x, float _y, float _z, float _w) : x(_x), y(_y), z(_z), w(_w) {}
    float& operator[](int i) { return (&x)[i]; }
    const float& operator[](int i) const { return (&x)[i]; }
};

struct mat4 {
    float m[4][4]; // column-major: m[col][row]

    mat4(float diag = 1.0f) {
        memset(m, 0, sizeof(m));
        m[0][0] = diag;
        m[1][1] = diag;
        m[2][2] = diag;
        m[3][3] = diag;
    }

    float* operator[](int col) { return m[col]; }
    const float* operator[](int col) const { return m[col]; }

    mat4 operator*(const mat4& rhs) const {
        mat4 res(0.0f);
        for (int c = 0; c < 4; ++c) {
            for (int r = 0; r < 4; ++r) {
                for (int k = 0; k < 4; ++k) {
                    res.m[c][r] += m[k][r] * rhs.m[c][k];
                }
            }
        }
        return res;
    }
};

inline float radians(float deg) {
    return deg * 0.01745329251994329576923690768489f;
}

} // namespace glm

#endif // GLM_GLM_HPP

