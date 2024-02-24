//
//  Node.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

protocol Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder)
}

class SceneNode {
    private let id = UUID()
    private var name: String = "Node"
    
    private(set) weak var parent: SceneNode?
    private(set) var children: [SceneNode] = []
    
    private(set) var position: SIMD3<Float> = .zero
    private(set) var scale: SIMD3<Float> = .one
    
    private(set) var forward: SIMD3<Float> = SIMD3<Float>(0, 0, 1)
    private(set) var up = SIMD3<Float>(0, 1, 0)
    var right: SIMD3<Float> {
        normalize(simd_cross(up, forward))
    }
    
    var rotationMatrix: float4x4 {
        float4x4(
            simd_float4(right.x, up.x, -forward.x, 0),
            simd_float4(right.y, up.y, -forward.y, 0),
            simd_float4(right.z, up.z, -forward.z, 0),
            simd_float4(      0,    0,          0, 1)
        )
    }
    
    var modelMatrix: float4x4 {
        var modelMatrix = matrix_identity_float4x4
        
        modelMatrix.scale(axis: scale)
        modelMatrix = matrix_multiply(modelMatrix, rotationMatrix)
        modelMatrix.translate(direction: position)
        
        if let parent {
            return matrix_multiply(parent.modelMatrix, modelMatrix)
        }
        
        return modelMatrix
    }
    
    func setPosition(_ position: SIMD3<Float>) {
        self.position = position
    }
    
    func rotate(around axis: Axis, by angleRadians: Radian) {
        let quaternion = simd_quaternion(angleRadians, axis.vector)
        
        forward = simd_act(quaternion, forward)
        up = simd_act(quaternion, up)
        
        let correctedRight = normalize(simd_cross(forward, up))
        up = normalize(simd_cross(correctedRight, forward))
    }
    
    func render(_ renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.pushDebugGroup("Rendering \(name)")
        
        if let renderable = self as? Renderable {
            renderable.doRender(renderCommandEncoder)
        }
        
        for child in children {
            child.render(renderCommandEncoder)
        }
        
        renderCommandEncoder.popDebugGroup()
    }
    
    func setPrent(_ parent: SceneNode) {
        self.parent = parent
    }
    
    func addChild(_ child: SceneNode) {
        child.setPrent(self)
        children.append(child)
    }
}
