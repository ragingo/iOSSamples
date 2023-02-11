//
//  Shaders.metal
//  Sample015-QRCode
//
//  Created by ragingo on 2023/02/05.
//

// https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf

#include <metal_stdlib>

using namespace metal;

struct ColorInOut
{
    float4 position [[ position ]];
    float2 texCoords;
};

struct BoundingBox
{
    float x;
    float y;
    float w;
    float h;
};

template <typename T> T deg2rad(T deg) {
    return deg * (M_PI_F / 180.0);
}

// https://github.com/ragingo/WebGLTest/blob/master/src/glsl/default_vs.glsl
float4x4 mat4_rotation_x(float rad) {
    return float4x4(float4(1.0, 0.0, 0.0, 0.0),
                    float4(0.0, cos(rad), -sin(rad), 0.0),
                    float4(0.0, sin(rad), cos(rad), 0.0),
                    float4(0.0, 0.0, 0.0, 1.0));
}

float4x4 mat4_rotation_y(float rad) {
    return float4x4(float4(cos(rad), 0.0, -sin(rad), 0.0),
                    float4(0.0, 1.0, 0.0, 0.0),
                    float4(sin(rad), 0.0, cos(rad), 0.0),
                    float4(0.0, 0.0, 0.0, 1.0));
}

float4x4 mat4_rotation_z(float rad) {
    return float4x4(float4(cos(rad), sin(rad), 0.0, 0.0),
                    float4(-sin(rad), cos(rad), 0.0, 0.0),
                    float4(0.0, 0.0, 1.0, 0.0),
                    float4(0.0, 0.0, 0.0, 1.0));
}

vertex ColorInOut default_vs(constant float4 *positions [[ buffer(0) ]],
                             constant float2 *texCoords [[ buffer(1) ]],
                             uint vid [[ vertex_id ]])
{
    ColorInOut out;
    out.position = mat4_rotation_z(deg2rad(-90.0)) * positions[vid];
    out.texCoords = texCoords[vid];
    return out;
}

template<typename T> bool between(T value, T min, T max) {
    return (min <= value) && (value <= max);
}

fragment float4 default_fs(ColorInOut in [[ stage_in ]],
                           texture2d<float> texture [[ texture(0) ]],
                           constant BoundingBox *boundingBox [[ buffer(1) ]])
{
    constexpr sampler colorSampler;
    float4 color = texture.sample(colorSampler, in.texCoords);

    const auto borderWidth = (1.0 / texture.get_width()) * 4.0;
    const auto pix_x = in.texCoords.x;
    const auto pix_y = in.texCoords.y;
    const auto box_l = boundingBox->x;
    const auto box_r = boundingBox->w;
    const auto box_t = boundingBox->y;
    const auto box_b = boundingBox->h;

    bool isLeftEdge   = between(pix_x, box_l - borderWidth, box_l) && between(pix_y, box_b, box_t);
    bool isRightEdge  = between(pix_x, box_r, box_r + borderWidth) && between(pix_y, box_b, box_t);
    bool isTopEdge    = between(pix_x, box_l - borderWidth, box_r + borderWidth) && between(pix_y, box_t - borderWidth, box_t);
    bool isBottomEdge = between(pix_x, box_l - borderWidth, box_r + borderWidth) && between(pix_y, box_b, box_b + borderWidth);

    if (isLeftEdge || isRightEdge || isTopEdge || isBottomEdge) {
        color = float4(1, 1, 0, 1);
    }

    return color;
}
