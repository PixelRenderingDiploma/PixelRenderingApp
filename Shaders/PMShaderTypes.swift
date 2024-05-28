//
//  PMShaderTypes.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import Foundation

struct Material {
    var color = simd_float4(0.6, 0.6, 0.6, 1.0)
    var isLit = true
    var useBaseTexture = false
    var useNormalMapTexture = false
    
    var ambient = simd_float3(0.1, 0.1, 0.1)
    var diffuse = simd_float3(1, 1, 1)
    var specular = simd_float3(1, 1, 1)
    var shininess: Float = 2
}
