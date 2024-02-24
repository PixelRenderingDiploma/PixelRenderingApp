//
//  ThreeDModelView.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-28.
//

import AppKit
import SceneKit

class ThreeDModelView: SCNView {
    let cameraNode = SCNNode()
    let contentNode = SCNNode()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        scene = SCNScene()
        
        cameraNode.camera = SCNCamera()
        cameraNode.name = "Camera"
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene?.rootNode.addChildNode(cameraNode)
        
        contentNode.name = "Content"
        contentNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene?.rootNode.addChildNode(contentNode)
        
        pointOfView = cameraNode
        
        setupLight()
    }
    
    private func setupLight() {
        let light = SCNLight()
        light.type = .directional // Set the light type to directional
        light.color = NSColor.white // Set the color of the light
        light.intensity = 1000 // Adjust the intensity as needed

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10) // Position the light above the scene
        
        // Optionally set the orientation of the light to shine down
        lightNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)

        scene?.rootNode.addChildNode(lightNode)
    }
}
