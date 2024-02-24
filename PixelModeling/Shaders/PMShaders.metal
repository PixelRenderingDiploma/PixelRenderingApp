//
//  PMShaders.metal
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-09.
//

#include <metal_stdlib>
using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands.
#include "PMShaderTypes.h"
#include "PMShared.metal"

struct Material {
    float4 color;
    bool isLit;
    bool useBaseTexture;
    bool useNormalMapTexture;
    
    float3 ambient;
    float3 diffuse;
    float3 specular;
    float shininess;
};

// Vertex shader outputs and fragment shader inputs
struct RasterizerData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float4 color;
    
    float2 textureCoordinate;
    
    float3 surfaceNormal;
    float3 surfaceTangent;
    float3 surfaceBitangent;
};

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant PMScene &sceneConstants [[ buffer(3) ]],
                                          constant float4x4 &modelConstants [[ buffer(2) ]]){
    RasterizerData rd;
    
    float4 worldPosition = modelConstants * float4(vIn.position, 1);
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.color = vIn.color;
    rd.textureCoordinate = vIn.textureCoordinate;
//    rd.worldPosition = worldPosition.xyz;
//    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
    
    rd.surfaceNormal = (modelConstants * float4(vIn.normal, 0.0)).xyz;
    rd.surfaceTangent = (modelConstants * float4(vIn.tangent, 0.0)).xyz;
    rd.surfaceBitangent = (modelConstants * float4(vIn.bitangent, 0.0)).xyz;
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]],
//                                     constant Material &material [[ buffer(1) ]],
//                                     constant int &lightCount [[ buffer(2) ]],
//                                     constant LightData *lightDatas [[ buffer(3) ]],
//                                     sampler sampler2d [[ sampler(0) ]],
                                     texture2d<float> baseColorMap [[ texture(0) ]],
                                     texture2d<float> normalMap [[ texture(1) ]]){
    float2 texCoord = rd.textureCoordinate;
    
//    float4 color = material.color;
//    if(material.useBaseTexture) {
//        color = baseColorMap.sample(sampler2d, texCoord);
//    }
//
//    if(material.isLit) {
//        float3 unitNormal = normalize(rd.surfaceNormal);
//        if(material.useNormalMapTexture) {
//            float3 sampleNormal = normalMap.sample(sampler2d, texCoord).rgb * 2 - 1;
//            float3x3 TBN = { rd.surfaceTangent, rd.surfaceBitangent, rd.surfaceNormal };
//            unitNormal = TBN * sampleNormal;
//        }
        
//        float3 unitToCameraVector = normalize(rd.toCameraVector); // V Vector
//
//        float3 phongIntensity = Lighting::GetPhongIntensity(material,
//                                                            lightDatas,
//                                                            lightCount,
//                                                            rd.worldPosition,
//                                                            unitNormal,
//                                                            unitToCameraVector);
//        color *= float4(phongIntensity, 1.0);
//    }
    
//    return half4(color.r, color.g, color.b, color.a);
    return half4(rd.color.r, rd.color.g, rd.color.b, rd.color.a);
}
