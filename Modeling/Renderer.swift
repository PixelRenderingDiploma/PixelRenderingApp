//
//  Renderer.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-09.
//

import Foundation

import simd
import MetalKit

class Renderer: NSObject {
    private var pipelineState: MTLRenderPipelineState?
    private var commandQueue: MTLCommandQueue?
    
    private(set) static var viewportSize: simd_float2 = .one
    static var aspectRation: Float {
        viewportSize.x / viewportSize.y
    }
    
    init?(with mtkView: MTKView) {
        super.init()
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Renderer.viewportSize.x = Float(size.width)
        Renderer.viewportSize.y = Float(size.height)
        print("Drawable size: \(size)")
    }
    
    func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = Engine.shared.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "My Command Buffer"
    
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderCommandEncoder?.label = "First Render Command Encoder"
        
        renderCommandEncoder?.pushDebugGroup("Starting Render")
            
        SceneManager.TickScene(renderCommandEncoder: renderCommandEncoder!, deltaTime: 1 / Float(view.preferredFramesPerSecond))
        
        renderCommandEncoder?.popDebugGroup()
        
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(view.currentDrawable!)
        commandBuffer?.commit()
    }
}
