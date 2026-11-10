#ifndef VIDEO365_EXPRESSION_ENGINE_H
#define VIDEO365_EXPRESSION_ENGINE_H

#include <string>
#include <vector>
#include <map>

/**
 * High-performance After Effects Expression & Math Engine.
 * Supports:
 *  - wiggle(freq, amp)
 *  - time * factor
 *  - linear(t, tMin, tMax, val1, val2)
 *  - ease(t, tMin, tMax, val1, val2)
 *  - loopOut("cycle") / loopOut("pingpong")
 *  - sin(time * freq) * amp
 */
class ExpressionEngine {
public:
    ExpressionEngine();
    ~ExpressionEngine();

    void init();
    float evaluateFloat(const std::string& expression, float time, float currentValue);
    std::vector<float> evaluateVector(const std::string& expression, float time, const std::vector<float>& currentValue);

    // Helpers
    static float smoothNoise(float x);
    static float parseWiggle(const std::string& expr, float& freq, float& amp);
    static float easeInOut(float t);
};

#endif //VIDEO365_EXPRESSION_ENGINE_H
