//
//  VertexDescriptorLibrary.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

enum VertexDescriptorTypes {
    case basic
}

class VertexDescriptorLibrary: Library<VertexDescriptorTypes, MTLVertexDescriptor> {
    var library: [VertexDescriptorTypes: VertexDescriptor] = [:]
    
    override func fillLibrary() {
        library.updateValue(BasicVertexDescriptor(), forKey: .basic)
    }
    
    override subscript(_ type: VertexDescriptorTypes) -> MTLVertexDescriptor? {
        library[type]?.vertexDescriptor
    }
}

protocol VertexDescriptor {
    var name: String { get }
    var vertexDescriptor: MTLVertexDescriptor { get }
}

public struct BasicVertexDescriptor: VertexDescriptor {
    var name: String = "Basic Vertex Descriptor"
    var vertexDescriptor: MTLVertexDescriptor
    
    init() {
        vertexDescriptor = MTLVertexDescriptor()
        
        var offset: Int = 0
        
        //Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        offset += MemoryLayout<simd_float3>.size
        
        //Color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = offset
        offset += MemoryLayout<simd_float4>.size
        
        //Texture Coordinate
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.attributes[2].offset = offset
        offset += MemoryLayout<simd_float3>.size // use float3 because of padding
        
        //Normal
        vertexDescriptor.attributes[3].format = .float3
        vertexDescriptor.attributes[3].bufferIndex = 0
        vertexDescriptor.attributes[3].offset = offset
        offset += MemoryLayout<simd_float3>.size
        
        //Tangent
        vertexDescriptor.attributes[4].format = .float3
        vertexDescriptor.attributes[4].bufferIndex = 0
        vertexDescriptor.attributes[4].offset = offset
        offset += MemoryLayout<simd_float3>.size
        
        //Bitangent
        vertexDescriptor.attributes[5].format = .float3
        vertexDescriptor.attributes[5].bufferIndex = 0
        vertexDescriptor.attributes[5].offset = offset
        offset += MemoryLayout<simd_float3>.size
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<PMVertex>.stride
    }
}
