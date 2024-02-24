//
//  RenderingViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-09.
//

import MetalKit

class RenderingViewController: PlatformViewController {
    private /*weak*/ var scene: Scene?
    private var renderer: Renderer?
    private var mtkView: MTKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.view as? MTKView,
              let device = view.device else {
            return
        }
        
        mtkView = view
        
        Engine.shared.start(device: device)
        
        let scene = SampleScene()
        SceneManager.setScene(scene)
        self.scene = scene
        
        guard let renderer = Renderer(with: view) else {
            return
        }
        
        self.renderer = renderer
        
        renderer.mtkView(view, drawableSizeWillChange: view.drawableSize)
        
        view.delegate = renderer;
        
        configureTapRecognizer()
    }
    
    private func configureTapRecognizer() {
        let recognizer = PlatformTapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(recognizer)
    }
    
    @objc func handleTap(_ gestureRecognizer: PlatformTapGestureRecognizer) {
        print("\(gestureRecognizer.location(in: self.view))")
    }
}

