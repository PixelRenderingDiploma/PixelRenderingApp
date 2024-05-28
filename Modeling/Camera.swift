//
//  Camera.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-10.
//

import Foundation

enum Axis {
    case x
    case y
    case z
    
    var vector: simd_float3 {
        switch self {
        case .x:
            [1, 0, 0]
        case .y:
            [0, 1, 0]
        case .z:
            [0, 0, 1]
        }
    }
}

class Camera: SceneNode {
    enum Placement {
        case axis(Axis)
        case custom(rotation: vector_float3)
    }
    
    var near: Float = 0.1
    var far: Float = 512
    var fov: Degree = 45
    
    var placement: Placement {
        @available(*, unavailable)
        get {
            fatalError("You cannot read from this object.")
        }
        set {
            
        }
    }
    
    var viewMatrix: float4x4 {
        var viewMatrix = matrix_identity_float4x4
        
        viewMatrix = matrix_multiply(viewMatrix, rotationMatrix)
        viewMatrix.translate(direction: -position)

        return viewMatrix
    }
    
    var projectionMatrix: float4x4 {
        return float4x4.perspective(fov: self.fov,
                                    aspectRatio: Renderer.aspectRation,
                                    near: self.near,
                                    far: self.far)
    }
}
