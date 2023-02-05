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

fragment float4 default_fs(ColorInOut in [[ stage_in ]],
                           texture2d<float> texture [[ texture(0) ]],
                           constant BoundingBox *boundingBox [[ buffer(1) ]])
{
    constexpr sampler colorSampler;
    float4 color = texture.sample(colorSampler, in.texCoords);

    if ((in.texCoords.x >= boundingBox->x && in.texCoords.x <= boundingBox->x + boundingBox->w) &&
        (in.texCoords.y >= boundingBox->y && in.texCoords.y <= boundingBox->y + boundingBox->h)) {
        color = float4(1, 0, 0, 1);
    }

//    if (in.texCoords.x >= 0.5 && in.texCoords.x <= 0.5 + boundingBox->w) {
//        color = float4(1, 0, 0, 1);
//    }

    return color;
}
