//
//  Mesh.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

class Mesh {
    private var vertices: [PMVertex]
    private var vertexCount: Int
    private var vertexBuffer: MTLBuffer? = nil
    
    private var indices: [UInt32]
    private var indexCount: Int
    private var indicesBuffer: MTLBuffer? = nil
    
    private var instanceCount: Int
    
    init(vertices: [PMVertex], indices: [UInt32] = [], instanceCount: Int = 1) {
        self.vertices = vertices
        self.vertexCount = vertices.count
        
        self.indices = indices
        self.indexCount = indices.count
        
        self.instanceCount = instanceCount
        
        self.createBuffer()
    }
    
    convenience init(primitive: Primitive, instanceCount: Int = 1) {
        self.init(vertices: primitive.vertices, indices: primitive.indices, instanceCount: instanceCount)
    }
    
    convenience init(shape: BasicShape) {
        let primitive: Primitive
        
        switch shape {
        case .cube:
            primitive = Cube()
        case .sphere:
            primitive = Sphere(radius: 1, rings: 8, sectors: 8)
        default:
            primitive = Cube()
        }
        
        self.init(primitive: primitive)
    }
    
    private func createBuffer() {
        guard vertexCount > 0 else {
            return
        }
        
        vertexBuffer = Engine.shared.device
            .makeBuffer(bytes: vertices,
                        length: MemoryLayout<PMVertex>.stride * vertexCount,
                        options: [])
        
        guard indexCount > 0 else {
            return
        }
        
        indicesBuffer = Engine.shared.device
            .makeBuffer(bytes: indices,
                        length: MemoryLayout<Int>.stride * indexCount,
                        options: [])
    }
    
    func drawPrimitives(_ renderCommandEncoder: MTLRenderCommandEncoder, material: Material? = nil) {
        guard let vertexBuffer else {
            return
        }
        
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        if let indicesBuffer {
            renderCommandEncoder.drawIndexedPrimitives(type: .triangle,
                                                       indexCount: indexCount,
                                                       indexType: .uint32,
                                                       indexBuffer: indicesBuffer,
                                                       indexBufferOffset: 0,
                                                       instanceCount: instanceCount)
        } else {
            renderCommandEncoder.drawPrimitives(type: .triangle,
                                                vertexStart: 0,
                                                vertexCount: vertices.count,
                                                instanceCount: instanceCount)
        }
    }
}
