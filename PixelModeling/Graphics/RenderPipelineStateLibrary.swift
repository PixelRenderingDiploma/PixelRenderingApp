//
//  RenderPipelineStateLibrary.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

enum RenderPipelineStateType {
    case basic
    case instanced
}

class RenderPipelineStateLibrary: Library<RenderPipelineStateType, MTLRenderPipelineState> {
    var library: [RenderPipelineStateType: RenderPipelineState] = [:]
    
    override func fillLibrary() {
        library.updateValue(BasicRenderPipelineState(), forKey: .basic)
//        library.updateValue(InstancedRenderPipelineState(), forKey: .instanced)
    }
    
    override subscript(_ type: RenderPipelineStateType) -> MTLRenderPipelineState? {
        return library[type]?.renderPipelineState
    }
}

class RenderPipelineState {
    var renderPipelineState: MTLRenderPipelineState
    
    init?(renderPipelineDescriptor: MTLRenderPipelineDescriptor) {
        do {
            renderPipelineState = try Engine.shared.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__::\(error.localizedDescription)")
            return nil
        }
    }
}

class BasicRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "Basic Render Pipeline Descriptor"
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.basic]
        
        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.basic]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.basicFragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)!
    }
}

class InstancedRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "Instanced Render Pipeline Descriptor"
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.basic]

        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.instanced]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.basicFragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)!
    }
}
