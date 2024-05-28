//
//  PMShaderTypes.h
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-09.
//

#ifndef PMShaderTypes_h
#define PMShaderTypes_h

#include <simd/simd.h>

typedef enum PMVertexInputIndex
{
    PMVertexInputIndexVertices     = 0,
    PMVertexInputIndexViewportSize = 1,
    PMVertexInputIndexModelData    = 2,
    PMVertexInputIndexSceneData    = 3,
} PMVertexInputIndex;

typedef struct
{
    vector_float3 position;
    vector_float4 color;
    vector_float2 texture;
    vector_float3 normal;
    vector_float3 tangent;
    vector_float3 bitangent;
} PMVertex;

typedef struct
{
    simd_float4x4 viewMatrix;
    simd_float4x4 projectionMatrix;
} PMScene;

#endif /* PMShaderTypes_h */
