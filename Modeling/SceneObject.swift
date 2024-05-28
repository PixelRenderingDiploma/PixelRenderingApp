//
//  SceneObject.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

class SceneObject: SceneNode {
    private(set) var mesh: Mesh
    
    init(mesh: Mesh) {
        self.mesh = mesh
        super.init()
    }
}

extension SceneObject: Renderable {
    func doRender(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.basic]!)
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.less])
        
        //Vertex Shader
        var matrix = modelMatrix
        renderCommandEncoder.setVertexBytes(&matrix, length: MemoryLayout<float4x4>.stride, index: Int(PMVertexInputIndexModelData.rawValue))
        
        mesh.drawPrimitives(renderCommandEncoder)
    }
}
