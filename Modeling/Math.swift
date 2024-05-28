//
//  Math.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import Foundation

typealias Degree = Float
typealias Radian = Float

extension Degree {
    var radian: Radian {
        return self / 180.0 * Float.pi
    }
}

extension Radian {
    var degree: Degree {
        return self * 180.0 / Float.pi
    }
}

extension float4x4 {
    mutating func translate(direction: simd_float3){
        var result = matrix_identity_float4x4
        
        let x = direction.x
        let y = direction.y
        let z = direction.z
        
        result.columns = (
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(x, y, z, 1)
        )
        
        self = matrix_multiply(self, result)
    }
    
    mutating func scale(axis: simd_float3){
        var result = matrix_identity_float4x4
        
        let x: Float = axis.x
        let y: Float = axis.y
        let z: Float = axis.z
        
        result.columns = (
            simd_float4(x, 0, 0, 0),
            simd_float4(0, y, 0, 0),
            simd_float4(0, 0, z, 0),
            simd_float4(0, 0, 0, 1)
        )
        
        self = matrix_multiply(self, result)
    }
    
    
    mutating func rotate(angle: Float, axis: simd_float3){
        var result = matrix_identity_float4x4
        
        let x = axis.x
        let y = axis.y
        let z = axis.z
        
        let c = cos(angle)
        let s = sin(angle)
        
        let mc = (1 - c)
        
        let r1c1 = x * x * mc + c
        let r2c1 = x * y * mc + z * s
        let r3c1 = x * z * mc - y * s
        let r4c1: Float = 0.0
        
        let r1c2 = y * x * mc - z * s
        let r2c2 = y * y * mc + c
        let r3c2 = y * z * mc + x * s
        let r4c2: Float = 0.0
        
        let r1c3 = z * x * mc + y * s
        let r2c3 = z * y * mc - x * s
        let r3c3 = z * z * mc + c
        let r4c3: Float = 0.0
        
        let r1c4: Float = 0.0
        let r2c4: Float = 0.0
        let r3c4: Float = 0.0
        let r4c4: Float = 1.0
        
        result.columns = (
            simd_float4(r1c1, r2c1, r3c1, r4c1),
            simd_float4(r1c2, r2c2, r3c2, r4c2),
            simd_float4(r1c3, r2c3, r3c3, r4c3),
            simd_float4(r1c4, r2c4, r3c4, r4c4)
        )
        
        self = matrix_multiply(self, result)
    }
    
    static func perspective(fov: Degree, aspectRatio: Float, near: Float, far: Float) -> matrix_float4x4 {
        let fov = fov.radian
        
        let t = tan(fov / 2)
        
        let x = 1 / (aspectRatio * t)
        let y = 1 / t
        let z = -((far + near) / (far - near))
        let w = -((2 * far * near) / (far - near))
        
        var result = matrix_identity_float4x4
        result.columns = (
            simd_float4(x,  0,  0,  0),
            simd_float4(0,  y,  0,  0),
            simd_float4(0,  0,  z, -1),
            simd_float4(0,  0,  w,  0)
        )
        
        return result
    }
}
