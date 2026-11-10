#ifndef VIDEO365_SHADERS_H
#define VIDEO365_SHADERS_H

// ==========================================
// 1. VERTEX SHADERS
// ==========================================

const char* VERTEX_SHADER = R"glsl(#version 300 es
layout(location = 0) in vec3 aPosition;
layout(location = 1) in vec2 aTexCoord;
out vec2 vTexCoord;
uniform mat4 uMVP;
void main() {
    gl_Position = uMVP * vec4(aPosition, 1.0);
    vTexCoord = aTexCoord;
}
)glsl";

// ==========================================
// 2. BASE PASSTHROUGH (OES External Video)
// ==========================================

const char* FRAGMENT_SHADER = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;
uniform float uOpacity;
void main() {
    fragColor = texture(uTexture, vTexCoord) * uOpacity;
}
)glsl";

// ==========================================
// 3. PROFESSIONAL EFFECTS (Module D)
// ==========================================

// Lumetri Color Grading: Exposure, Contrast, Saturation, Balance Tint
const char* EFFECT_LUMETRI_COLOR = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;

uniform float uExposure;   // -3.0 to 3.0
uniform float uContrast;   // 0.5 to 1.5
uniform float uSaturation; // 0.0 to 2.0
uniform vec3 uTint;        // RGB balance gain

void main() {
    vec4 color = texture(uTexture, vTexCoord);

    // 1. Exposure
    color.rgb *= pow(2.0, uExposure);

    // 2. Contrast
    color.rgb = (color.rgb - 0.5) * uContrast + 0.5;

    // 3. Saturation
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(luma), color.rgb, uSaturation);

    // 4. Color Tint
    color.rgb *= uTint;

    fragColor = vec4(clamp(color.rgb, 0.0, 1.0), color.a);
}
)glsl";

// Chromatic Aberration: Color fringe RGB split
const char* EFFECT_CHROMATIC_ABERRATION = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;
uniform float uAmount;
void main() {
    vec2 offset = vec2(uAmount, 0.0) * 0.02;
    float r = texture(uTexture, vTexCoord + offset).r;
    float g = texture(uTexture, vTexCoord).g;
    float b = texture(uTexture, vTexCoord - offset).b;
    fragColor = vec4(r, g, b, 1.0);
}
)glsl";

// Advanced Chroma Key / Green Screen with Spill Suppression
const char* EFFECT_CHROMA_KEY = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;
uniform vec3 uKeyColor;   // e.g. vec3(0.0, 1.0, 0.0)
uniform float uThreshold; // e.g. 0.4
uniform float uSmoothness;// e.g. 0.1

void main() {
    vec4 color = texture(uTexture, vTexCoord);
    float diff = length(color.rgb - uKeyColor);
    float alpha = smoothstep(uThreshold, uThreshold + uSmoothness, diff);
    
    // Spill suppression: desaturate key color if near threshold
    if (diff < uThreshold + uSmoothness * 2.0) {
        color.g = min(color.g, max(color.r, color.b));
    }
    
    fragColor = vec4(color.rgb, color.a * alpha);
}
)glsl";

// Unmult: Remove black background for fire/smoke/sparks overlays
const char* EFFECT_UNMULT = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;

void main() {
    vec4 color = texture(uTexture, vTexCoord);
    float alpha = max(max(color.r, color.g), color.b);
    if (alpha > 0.001) {
        fragColor = vec4(color.rgb / alpha, alpha);
    } else {
        fragColor = vec4(0.0);
    }
}
)glsl";

// Vignette & Cinematic Edge Darkness
const char* EFFECT_VIGNETTE = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;
uniform float uRadius;    // e.g. 0.75
uniform float uSoftness;  // e.g. 0.45

void main() {
    vec4 color = texture(uTexture, vTexCoord);
    vec2 position = vTexCoord - vec2(0.5);
    float dist = length(position);
    float vignette = smoothstep(uRadius, uRadius - uSoftness, dist);
    fragColor = vec4(color.rgb * vignette, color.a);
}
)glsl";

// ==========================================
// 4. PROFESSIONAL TRANSITIONS (Module E)
// ==========================================

// 1. Cross Dissolve
const char* TRANSITION_DISSOLVE = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
void main() {
    vec4 from = texture(uTextureFrom, vTexCoord);
    vec4 to = texture(uTextureTo, vTexCoord);
    fragColor = mix(from, to, uProgress);
}
)glsl";

// 2. Whip Pan
const char* TRANSITION_WHIP_PAN = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
uniform vec2 uDirection; // e.g. (1.0, 0.0)
void main() {
    vec2 offset = uDirection * uProgress;
    vec2 uvFrom = vTexCoord + offset;
    vec2 uvTo = vTexCoord - (uDirection - offset);
    vec4 from = (all(greaterThanEqual(uvFrom, vec2(0.0))) && all(lessThanEqual(uvFrom, vec2(1.0)))) ? texture(uTextureFrom, uvFrom) : vec4(0.0);
    vec4 to = (all(greaterThanEqual(uvTo, vec2(0.0))) && all(lessThanEqual(uvTo, vec2(1.0)))) ? texture(uTextureTo, uvTo) : vec4(0.0);
    fragColor = from + to;
}
)glsl";

// 3. Procedural Glitch Transition
const char* TRANSITION_GLITCH = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123); }
void main() {
    vec2 p = vTexCoord;
    float jitter = hash(vec2(p.y, uProgress)) * 2.0 - 1.0;
    jitter *= step(0.9, hash(vec2(uProgress, uProgress))) * 0.1 * uProgress;
    vec4 from = texture(uTextureFrom, p + vec2(jitter, 0.0));
    vec4 to = texture(uTextureTo, p - vec2(jitter, 0.0));
    fragColor = mix(from, to, uProgress);
    if (hash(p + uProgress) > 0.95) fragColor.rgb += 0.2;
}
)glsl";

// 4. Zoom Transition
const char* TRANSITION_ZOOM = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
void main() {
    vec2 center = vec2(0.5);
    float zoomFrom = 1.0 + uProgress * 3.0;
    float zoomTo = 0.05 + (1.0 - uProgress) * 0.95;
    vec2 uvFrom = (vTexCoord - center) / zoomFrom + center;
    vec2 uvTo = (vTexCoord - center) / zoomTo + center;
    vec4 from = (all(greaterThanEqual(uvFrom, vec2(0.0))) && all(lessThanEqual(uvFrom, vec2(1.0)))) ? texture(uTextureFrom, uvFrom) : vec4(0.0);
    vec4 to = (all(greaterThanEqual(uvTo, vec2(0.0))) && all(lessThanEqual(uvTo, vec2(1.0)))) ? texture(uTextureTo, uvTo) : vec4(0.0);
    fragColor = mix(from, to, smoothstep(0.4, 0.6, uProgress));
}
)glsl";

// 5. Vintage Film Burn
const char* TRANSITION_FILM_BURN = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
float noise(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec4 from = texture(uTextureFrom, vTexCoord);
    vec4 to = texture(uTextureTo, vTexCoord);
    float burn = smoothstep(0.0, 0.5, uProgress) * smoothstep(1.0, 0.5, uProgress);
    vec3 burnColor = vec3(1.0, 0.4, 0.1) * burn * 2.5;
    fragColor = mix(from, to, uProgress);
    fragColor.rgb += burnColor * noise(vTexCoord + uProgress);
}
)glsl";

// 6. Radial Blur / Spin Transition
const char* TRANSITION_RADIAL_BLUR = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
void main() {
    vec2 center = vec2(0.5);
    vec2 toCenter = center - vTexCoord;
    vec4 color = vec4(0.0);
    float total = 0.0;
    for (float i = 0.0; i <= 10.0; i += 1.0) {
        float percent = (i / 10.0) * uProgress * 0.1;
        vec4 sFrom = texture(uTextureFrom, vTexCoord + toCenter * percent);
        vec4 sTo = texture(uTextureTo, vTexCoord + toCenter * percent);
        color += mix(sFrom, sTo, uProgress);
        total += 1.0;
    }
    fragColor = color / total;
}
)glsl";

// 7. Swirl / Vortex Transition
const char* TRANSITION_SWIRL = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
void main() {
    float angle = uProgress * 3.14159 * 2.0;
    vec2 center = vec2(0.5);
    vec2 offset = vTexCoord - center;
    float dist = length(offset);
    float theta = atan(offset.y, offset.x) + (1.0 - smoothstep(0.0, 0.5, dist)) * angle;
    vec2 swirlUV = center + vec2(cos(theta), sin(theta)) * dist;
    
    vec4 from = texture(uTextureFrom, swirlUV);
    vec4 to = texture(uTextureTo, swirlUV);
    fragColor = mix(from, to, uProgress);
}
)glsl";

// 8. Directional Linear Wipe / Push
const char* TRANSITION_WIPE = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
void main() {
    vec4 from = texture(uTextureFrom, vTexCoord);
    vec4 to = texture(uTextureTo, vTexCoord);
    float border = smoothstep(uProgress - 0.02, uProgress + 0.02, vTexCoord.x);
    fragColor = mix(to, from, border);
}
)glsl";

// 9. Water Ripple / Wave Distortion
const char* TRANSITION_WAVE = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
void main() {
    vec2 p = vTexCoord - vec2(0.5);
    float dist = length(p);
    float wave = sin(dist * 30.0 - uProgress * 15.0) * 0.03 * (1.0 - uProgress);
    vec2 uv = vTexCoord + (p / (dist + 0.001)) * wave;
    vec4 from = texture(uTextureFrom, uv);
    vec4 to = texture(uTextureTo, uv);
    fragColor = mix(from, to, uProgress);
}
)glsl";

// 10. Doorway 3D Perspective Transition
const char* TRANSITION_DOORWAY = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
void main() {
    vec2 p = vTexCoord;
    float scale = 1.0 + uProgress * 0.8;
    vec2 center = vec2(0.5);
    vec2 uvTo = (p - center) / scale + center;
    vec4 to = (all(greaterThanEqual(uvTo, vec2(0.0))) && all(lessThanEqual(uvTo, vec2(1.0)))) ? texture(uTextureTo, uvTo) : vec4(0.0);
    
    vec4 from = texture(uTextureFrom, p);
    float split = abs(p.x - 0.5);
    if (split < uProgress * 0.5) {
        fragColor = to;
    } else {
        fragColor = mix(from, to, uProgress * 0.5);
    }
}
)glsl";

// ==========================================
// 5. AI EFFECTS (Module C)
// ==========================================

const char* SHADER_DOLLY_ZOOM = R"glsl(#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform samplerExternalOES uTexture;
uniform vec2 uFaceCenter;
uniform float uZoom;
void main() {
    vec2 uv = (vTexCoord - uFaceCenter) / uZoom + uFaceCenter;
    if (all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)))) {
        fragColor = texture(uTexture, uv);
    } else {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
}
)glsl";

const char* SHADER_OBJECT_TRACK = R"glsl(#version 300 es
precision highp float;
in vec2 vTexCoord;
out vec4 fragColor;
uniform sampler2D uLayerTexture;
uniform vec2 uObjectPos;
uniform float uScale;
void main() {
    vec2 uv = (vTexCoord - uObjectPos) / uScale + vec2(0.5);
    if (all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)))) {
        fragColor = texture(uLayerTexture, uv);
    } else {
        discard;
    }
}
)glsl";

#endif //VIDEO365_SHADERS_H
