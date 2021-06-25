//
//  Shaders.metal
//  App
//
//  Created by ragingo on 2021/06/21.
//

#include <metal_stdlib>
#include <simd/simd.h>

#import "ShaderTypes.h"

using namespace metal;

struct ColorInOut
{
    float4 position [[ position ]];
    float2 texCoords;
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
                           texture2d<float> texture [[ texture(0) ]])
{
    constexpr sampler colorSampler;
    float4 color = texture.sample(colorSampler, in.texCoords);
    color = color.bgra;
    return color;
}
