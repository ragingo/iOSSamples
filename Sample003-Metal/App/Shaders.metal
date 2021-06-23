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
};

vertex ColorInOut default_vs(constant float4 *positions [[ buffer(0) ]],
                             uint vid [[ vertex_id ]])
{
    ColorInOut out;
    out.position = positions[vid];
    return out;
}

fragment float4 default_fs(ColorInOut in [[ stage_in ]])
{
    return float4(1, 0, 0, 1);
}
