//
//  ThreeDModelDetailedViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-28.
//

import AppKit
import SceneKit
import GLTFSceneKit

class ThreeDModelDetailedViewController: NSViewController {
    @IBOutlet weak var sceneView: ThreeDModelView?
    
    var storageItem: StorageItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .clear
        
        self.sceneView?.delegate = self
        
        registerGestures()
        reload()
    }
    
    func registerGestures() {
        let gestures = [
            {
                let gesture = PlatformPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
#if os(iOS)
                gesture.maximumNumberOfTouches = 1
#endif
                return gesture
            }(),
            PlatformPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        ]
        
        for gesture in gestures {
            sceneView?.addGestureRecognizer(gesture)
        }
    }
    
    func update(with item: StorageItem?) {
        self.storageItem = item
    }
    
    func reload() {
        guard let url = storageItem?.url else {
            return
        }
        
        updateScene(with: url)
    }
    
    func updateScene(with url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        
        let scneneSource = GLTFSceneSource(data: data)
        
        do {
            let loadedScene = try scneneSource.scene(options: nil)
            
            DispatchQueue.main.async { [weak self] in
                self?.sceneView?.contentNode.childNodes.forEach { $0.removeFromParentNode() }

                let copiedRoot = loadedScene.rootNode.clone()
                copiedRoot
                    .childNodes { node, _ in node.geometry?.firstMaterial != nil }
                    .forEach { node in
                        node.geometry = node.geometry?.copy() as? SCNGeometry
                    }
                
                var maxDimension = max(
                    copiedRoot.boundingBox.max.x - copiedRoot.boundingBox.min.x,
                    copiedRoot.boundingBox.max.y - copiedRoot.boundingBox.min.y,
                    copiedRoot.boundingBox.max.z - copiedRoot.boundingBox.min.z)
                maxDimension = maxDimension == 0 ? 1 : maxDimension
                maxDimension *= 1.1 // Making sure there's a bit of padding.
                
                self?.sceneView?.contentNode.simdScale = simd_float3(repeating: 1) * Float(2.5 / maxDimension)
                self?.sceneView?.contentNode.addChildNode(copiedRoot)
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: Gestures
    
    private var lastSwipeLocation: CGPoint?
    
    @objc
    func handlePan(_ gesture: PlatformPanGestureRecognizer) {
        guard let contentNode = sceneView?.contentNode else {
            return
        }
        
        switch gesture.state {
        case .began:
            lastSwipeLocation = gesture.location(in: sceneView)
        case .changed:
            let location = gesture.location(in: sceneView)
            
            guard let lastSwipeLocation else {
                return
            }
            
            let delta = CGSize(
                width: location.x - lastSwipeLocation.x,
                height: location.y - lastSwipeLocation.y
            )
            
#if os(iOS)
            let rotationX = SCNMatrix4MakeRotation(CGFloat(Float(delta.height)) * 0.02, 1, 0, 0)
#else
            let rotationX = SCNMatrix4MakeRotation(CGFloat(Float(delta.height)) * 0.02, -1, 0, 0)
#endif
            let rotationY = SCNMatrix4MakeRotation(CGFloat(Float(delta.width)) * 0.02, 0, 1, 0)
            let rotation = SCNMatrix4Mult(rotationX, rotationY)
            
            contentNode.transform = SCNMatrix4Mult(contentNode.transform, rotation)
            
            self.lastSwipeLocation = location
        case .ended:
            lastSwipeLocation = nil
        default:
            break
        }
    }
    
    private var initialScale: simd_float3?
    
    @objc
    func handlePinch(_ gesture: PlatformPinchGestureRecognizer) {
        guard let contentNode = sceneView?.contentNode else {
            return
        }
        
        switch gesture.state {
        case .began:
            initialScale = contentNode.simdScale
        case .changed:
            guard let initialScale else {
                initialScale = contentNode.simdScale
                return
            }
            
            contentNode.simdScale = initialScale * Float(gesture.scale)
        case .ended:
            initialScale = nil
        default:
            break
        }
    }
}

extension ThreeDModelDetailedViewController: SCNSceneRendererDelegate {}
