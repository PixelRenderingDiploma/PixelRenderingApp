//
//  SampleScene.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import Foundation

class SampleScene: Scene {
    var cube: SceneNode = SceneObject(mesh: Mesh(primitive: Cube()))
    var sphere: SceneNode = SceneObject(mesh: Mesh(primitive: Sphere(radius: 1, rings: 8, sectors: 8)))
    
    override init() {
        super.init()
        
        let url = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appending(path: "test").appendingPathExtension(for: .obj)
//        OBJHelper().export(primitive: Sphere(radius: 1, rings: 8, sectors: 8), to: url)
//        OBJHelper().export(primitive: Cube(), to: url)
        
        root.addChild(cube)
        camera.setPosition(SIMD3<Float>(0, 0, -8))
    }
    
    override func update() {
        cube.rotate(around: .y, by: 0.01)
        cube.rotate(around: .x, by: 0.01)
    }
}
