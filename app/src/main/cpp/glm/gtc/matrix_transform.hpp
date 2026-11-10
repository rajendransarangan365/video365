#ifndef GLM_GTC_MATRIX_TRANSFORM_HPP
#define GLM_GTC_MATRIX_TRANSFORM_HPP

#include "../glm.hpp"

namespace glm {

inline mat4 translate(const mat4& m, const vec3& v) {
    mat4 res = m;
    res[3][0] = m[0][0] * v.x + m[1][0] * v.y + m[2][0] * v.z + m[3][0];
    res[3][1] = m[0][1] * v.x + m[1][1] * v.y + m[2][1] * v.z + m[3][1];
    res[3][2] = m[0][2] * v.x + m[1][2] * v.y + m[2][2] * v.z + m[3][2];
    res[3][3] = m[0][3] * v.x + m[1][3] * v.y + m[2][3] * v.z + m[3][3];
    return res;
}

inline mat4 scale(const mat4& m, const vec3& v) {
    mat4 res = m;
    res[0][0] = m[0][0] * v.x;
    res[0][1] = m[0][1] * v.x;
    res[0][2] = m[0][2] * v.x;
    res[0][3] = m[0][3] * v.x;

    res[1][0] = m[1][0] * v.y;
    res[1][1] = m[1][1] * v.y;
    res[1][2] = m[1][2] * v.y;
    res[1][3] = m[1][3] * v.y;

    res[2][0] = m[2][0] * v.z;
    res[2][1] = m[2][1] * v.z;
    res[2][2] = m[2][2] * v.z;
    res[2][3] = m[2][3] * v.z;
    return res;
}

inline mat4 rotate(const mat4& m, float angle, const vec3& v) {
    float c = cosf(angle);
    float s = sinf(angle);
    float len = sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
    if (len == 0.0f) return m;
    float x = v.x / len, y = v.y / len, z = v.z / len;

    mat4 rot(1.0f);
    rot[0][0] = c + (1.0f - c) * x * x;
    rot[0][1] = (1.0f - c) * x * y + s * z;
    rot[0][2] = (1.0f - c) * x * z - s * y;

    rot[1][0] = (1.0f - c) * x * y - s * z;
    rot[1][1] = c + (1.0f - c) * y * y;
    rot[1][2] = (1.0f - c) * y * z + s * x;

    rot[2][0] = (1.0f - c) * x * z + s * y;
    rot[2][1] = (1.0f - c) * y * z - s * x;
    rot[2][2] = c + (1.0f - c) * z * z;

    return m * rot;
}

inline mat4 ortho(float left, float right, float bottom, float top, float zNear, float zFar) {
    mat4 res(1.0f);
    res[0][0] = 2.0f / (right - left);
    res[1][1] = 2.0f / (top - bottom);
    res[2][2] = -2.0f / (zFar - zNear);
    res[3][0] = -(right + left) / (right - left);
    res[3][1] = -(top + bottom) / (top - bottom);
    res[3][2] = -(zFar + zNear) / (zFar - zNear);
    return res;
}

} // namespace glm

#endif // GLM_GTC_MATRIX_TRANSFORM_HPP

