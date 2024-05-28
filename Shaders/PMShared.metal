//
//  PMShared.metal
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinate [[ attribute(2) ]];
    float3 normal [[ attribute(3) ]];
    float3 tangent [[ attribute(4) ]];
    float3 bitangent [[ attribute(5) ]];
};
