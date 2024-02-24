//
//  Scene.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

class Scene {
    private(set) var name = "Scene"
    private(set) var root = SceneNode()
    private(set) var camera = Camera()
    
    func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering Scene \(name)")
        var sceneData = PMScene(viewMatrix: camera.viewMatrix, projectionMatrix: camera.projectionMatrix)
        renderCommandEncoder.setVertexBytes(&sceneData, length: MemoryLayout<PMScene>.stride, index: Int(PMVertexInputIndexSceneData.rawValue))
        
        root.render(renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
    
    func update() {
        
    }
}

class CamerasManager {
    private(set) var cameras: [Camera] = []
}
