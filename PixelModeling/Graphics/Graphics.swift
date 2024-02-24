//
//  Graphics.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import Foundation

class Graphics {
    private(set) static var shaders = ShadersLibrary()
    private(set) static var vertexDescriptors = VertexDescriptorLibrary()
    private(set) static var renderPipelineStates = RenderPipelineStateLibrary()
    private(set) static var depthStencilStates = DepthStencilStateLibrary()
    private(set) static var samplerStates = SamplerStateLibrary()
}

class Library<K, V> {
    init() {
        self.fillLibrary()
    }
    
    func fillLibrary() {}
    subscript(_ type: K) -> V? { return nil }
}
