//
//  Shaders.metal
//  Sample015-QRCode
//
//  Created by ragingo on 2023/02/05.
//

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

vertex ColorInOut default_vs(constant float4 *positions [[ buffer(0) ]],
                             constant float2 *texCoords [[ buffer(1) ]],
                             uint vid [[ vertex_id ]])
{
    ColorInOut out;
    out.position = positions[vid];
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
