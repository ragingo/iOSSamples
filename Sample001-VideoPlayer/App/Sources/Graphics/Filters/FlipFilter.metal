//
//  FlipFilter.metal
//  App
//
//  Created by ragingo on 2021/06/15.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

extern "C" float4 flip(coreimage::sampler s) {
    float2 coord = s.coord();
    coord.x = 1.0f - coord.x;
    return s.sample(coord);
}
