#include "expression_engine.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <android/log.h>
#include <algorithm>

#define LOG_TAG "ExpressionEngine"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

ExpressionEngine::ExpressionEngine() {
    init();
}

ExpressionEngine::~ExpressionEngine() {}

void ExpressionEngine::init() {
    LOGI("Expression Engine Initialized (AE Math & Wiggle)");
}

float ExpressionEngine::smoothNoise(float x) {
    float i = floorf(x);
    float f = x - i;
    float u = f * f * (3.0f - 2.0f * f); // Cubic Hermite curve

    float n0 = sinf(i * 12.9898f + 78.233f) * 43758.5453f;
    n0 = (n0 - floorf(n0)) * 2.0f - 1.0f;

    float n1 = sinf((i + 1.0f) * 12.9898f + 78.233f) * 43758.5453f;
    n1 = (n1 - floorf(n1)) * 2.0f - 1.0f;

    return n0 * (1.0f - u) + n1 * u;
}

float ExpressionEngine::easeInOut(float t) {
    t = std::max(0.0f, std::min(1.0f, t));
    return t * t * (3.0f - 2.0f * t);
}

float ExpressionEngine::parseWiggle(const std::string& expr, float& freq, float& amp) {
    freq = 2.0f;
    amp = 30.0f;
    size_t openParen = expr.find('(');
    size_t closeParen = expr.find(')');
    if (openParen != std::string::npos && closeParen != std::string::npos && closeParen > openParen) {
        std::string args = expr.substr(openParen + 1, closeParen - openParen - 1);
        float f = 0.0f, a = 0.0f;
        if (sscanf(args.c_str(), "%f,%f", &f, &a) == 2 || sscanf(args.c_str(), "%f , %f", &f, &a) == 2) {
            freq = f;
            amp = a;
        }
    }
    return true;
}

float ExpressionEngine::evaluateFloat(const std::string& expression, float time, float currentValue) {
    if (expression.empty()) return currentValue;

    // 1. wiggle(freq, amp)
    if (expression.find("wiggle") != std::string::npos) {
        float freq = 2.0f, amp = 30.0f;
        parseWiggle(expression, freq, amp);
        float offset = smoothNoise(time * freq) * amp;
        return currentValue + offset;
    }

    // 2. time * factor
    if (expression.find("time") != std::string::npos) {
        float factor = 1.0f;
        size_t mul = expression.find('*');
        if (mul != std::string::npos) {
            sscanf(expression.c_str() + mul + 1, "%f", &factor);
        }
        return time * factor;
    }

    // 3. sin(time * freq) * amp
    if (expression.find("sin") != std::string::npos) {
        float freq = 1.0f, amp = 1.0f;
        size_t openP = expression.find('(');
        size_t closeP = expression.find(')');
        if (openP != std::string::npos && closeP != std::string::npos) {
            size_t mul = expression.find('*', closeP);
            if (mul != std::string::npos) {
                sscanf(expression.c_str() + mul + 1, "%f", &amp);
            }
        }
        return sinf(time * 3.14159f * 2.0f * freq) * amp;
    }

    return currentValue;
}

std::vector<float> ExpressionEngine::evaluateVector(const std::string& expression, float time, const std::vector<float>& currentValue) {
    std::vector<float> result = currentValue;
    if (result.empty()) return result;

    if (expression.find("wiggle") != std::string::npos) {
        float freq = 2.0f, amp = 30.0f;
        parseWiggle(expression, freq, amp);

        // Multi-dimensional wiggle with decorrelated seeds
        for (size_t i = 0; i < result.size(); ++i) {
            float seedOffset = (float)i * 100.0f;
            result[i] += smoothNoise((time + seedOffset) * freq) * amp;
        }
    }

    return result;
}
