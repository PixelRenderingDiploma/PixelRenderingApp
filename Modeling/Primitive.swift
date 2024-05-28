//
//  Primitive.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import Foundation

protocol Primitive {
    var vertices: [PMVertex] { get }
    var indices: [UInt32] { get }
}

struct Cube: Primitive {
    var indices: [UInt32] { [] }
    
    var vertices: [PMVertex] = {
        [
            // Front face
            PMVertex(position: [-1, 1, 1], color: [1.0, 0.5, 0.0, 1.0], texture: [0, 0], normal: [ 0, 0, 1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1,-1, 1], color: [0.0, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 0, 0, 1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1,-1, 1], color: [0.5, 0.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 0, 1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1, 1, 1], color: [1.0, 1.0, 0.5, 1.0], texture: [0, 0], normal: [ 0, 0, 1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1, 1, 1], color: [0.0, 1.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 0, 1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1,-1, 1], color: [1.0, 0.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 0, 1], tangent: .zero, bitangent: .zero),

            // Back face
            PMVertex(position: [ 1.0, 1.0,-1.0], color: [1.0, 0.5, 0.0, 1.0], texture: [0, 0], normal: [ 0, 0,-1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0,-1.0,-1.0], color: [0.5, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 0, 0,-1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0, 1.0,-1.0], color: [0.0, 0.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 0,-1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0, 1.0,-1.0], color: [1.0, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 0, 0,-1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0,-1.0,-1.0], color: [0.0, 1.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 0,-1], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0,-1.0,-1.0], color: [1.0, 0.5, 1.0, 1.0], texture: [0, 0], normal: [ 0, 0,-1], tangent: .zero, bitangent: .zero),

            // Left face
            PMVertex(position: [-1.0,-1.0,-1.0], color: [1.0, 0.5, 0.0, 1.0], texture: [0, 0], normal: [-1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0,-1.0, 1.0], color: [0.0, 1.0, 0.5, 1.0], texture: [0, 0], normal: [-1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0, 1.0, 1.0], color: [0.0, 0.5, 1.0, 1.0], texture: [0, 0], normal: [-1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0,-1.0,-1.0], color: [1.0, 1.0, 0.0, 1.0], texture: [0, 0], normal: [-1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0, 1.0, 1.0], color: [0.0, 1.0, 1.0, 1.0], texture: [0, 0], normal: [-1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0, 1.0,-1.0], color: [1.0, 0.0, 1.0, 1.0], texture: [0, 0], normal: [-1, 0, 0], tangent: .zero, bitangent: .zero),

            // Right face
            PMVertex(position: [ 1.0, 1.0, 1.0], color: [1.0, 0.0, 0.5, 1.0], texture: [0, 0], normal: [ 1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0,-1.0,-1.0], color: [0.0, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0, 1.0,-1.0], color: [0.0, 0.5, 1.0, 1.0], texture: [0, 0], normal: [ 1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0,-1.0,-1.0], color: [1.0, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0, 1.0, 1.0], color: [0.0, 1.0, 1.0, 1.0], texture: [0, 0], normal: [ 1, 0, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0,-1.0, 1.0], color: [1.0, 0.5, 1.0, 1.0], texture: [0, 0], normal: [ 1, 0, 0], tangent: .zero, bitangent: .zero),

            // Top face
            PMVertex(position: [ 1.0, 1.0, 1.0], color: [1.0, 0.0, 0.0, 1.0], texture: [0, 0], normal: [ 0, 1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0, 1.0,-1.0], color: [0.0, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 0, 1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0, 1.0,-1.0], color: [0.0, 0.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0, 1.0, 1.0], color: [1.0, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 0, 1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0, 1.0,-1.0], color: [0.5, 1.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0, 1.0, 1.0], color: [1.0, 0.0, 1.0, 1.0], texture: [0, 0], normal: [ 0, 1, 0], tangent: .zero, bitangent: .zero),

            // Bottom face
            PMVertex(position: [ 1.0,-1.0, 1.0], color: [1.0, 0.5, 0.0, 1.0], texture: [0, 0], normal: [ 0,-1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0,-1.0,-1.0], color: [0.5, 1.0, 0.0, 1.0], texture: [0, 0], normal: [ 0,-1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0,-1.0,-1.0], color: [0.0, 0.0, 1.0, 1.0], texture: [0, 0], normal: [ 0,-1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [ 1.0,-1.0, 1.0], color: [1.0, 1.0, 0.5, 1.0], texture: [0, 0], normal: [ 0,-1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0,-1.0, 1.0], color: [0.0, 1.0, 1.0, 1.0], texture: [0, 0], normal: [ 0,-1, 0], tangent: .zero, bitangent: .zero),
            PMVertex(position: [-1.0,-1.0,-1.0], color: [1.0, 0.5, 1.0, 1.0], texture: [0, 0], normal: [ 0,-1, 0], tangent: .zero, bitangent: .zero)
        ]
    }()
}

struct Sphere: Primitive {
    var vertices: [PMVertex]
    var indices: [UInt32]
    
    init(radius: Float, rings: Int, sectors: Int) {
        var vertices = [PMVertex]()
        var indices = [Int]()
        
        let startRing: Int = -rings / 2 + 1;
        let endRing: Int = rings / 2 - 1;
        
        let souhPolePosition: simd_float3 = [0, -radius, 0]
        vertices.append(PMVertex(position: souhPolePosition, color: [1, 1, 0, 1], texture: [0, 0], normal: normalize(souhPolePosition), tangent: .zero, bitangent: .zero))
        
        for ring in startRing..<endRing+1 {
            let phi = Float.pi * Float(ring) / Float((rings - 1))
            let cosPhi = cos(phi);
            let sinPhi = sin(phi);
            
            for sector in 0..<sectors {
                let theta = 2 * Float.pi * Float(sector) / Float(sectors - 1);
                let cosTheta = cos(theta);
                let sinTheta = sin(theta);
                
                let position: simd_float3 = [radius * cosTheta * cosPhi,
                                             radius * sinPhi,
                                             radius * sinTheta * cosPhi]
                let color: simd_float4 = [1, 0, 0, 1]
                let texcoord: simd_float2 = [Float(sector) / Float(sectors - 1), Float(ring) / Float(rings - 1)]
                let normal = normalize(position)
                vertices.append(PMVertex(position: position, color: color, texture: texcoord, normal: normal, tangent: .zero, bitangent: .zero))
            }
        }
        
        let northePolePosition: simd_float3 = [0, radius, 0]
        vertices.append(PMVertex(position: northePolePosition, color: [1, 1, 0, 1], texture: [0, 0], normal: normalize(northePolePosition), tangent: .zero, bitangent: .zero))
        
        //South Pole
        for sector in 1..<sectors {
            indices.append(0);
            indices.append(sector);
            indices.append(sector + 1);
        }
        
        //Main Part
        for ring in 0..<rings-2 {
            for sector in 0..<sectors-1 {
                let currentRow = ring * sectors;
                let nextRow = (ring + 1) * sectors;
                
                indices.append(currentRow + sector + 1);
                indices.append(nextRow + sector + 1);
                indices.append(currentRow + sector + 2);
                
                indices.append(nextRow + sector + 1);
                indices.append(nextRow + sector + 2);
                indices.append(currentRow + sector + 2);
            }
        }
        
        //North Pole
        for sector in 0..<sectors {
            indices.append(vertices.count - 1);
            indices.append(vertices.count - 1 - sector);
            indices.append(vertices.count - 1 - sector - 1);
        }
        
        self.vertices = vertices
        self.indices = indices.map { UInt32($0) }
    }
}
