//
//  SceneManager.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

class SceneManager {
    private static var scenes: [Scene] = []
    private static weak var currentScene: Scene?
    
    static func setScene(_ scene: Scene) {
        currentScene = scene
        scenes.append(scene)
    }
    
    public static func TickScene(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        guard let scene = currentScene else {
            return
        }
        
        scene.update()
        scene.render(renderCommandEncoder)
    }
}
