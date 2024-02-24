//
//  SCNPreviewGenerator.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-27.
//

import SceneKit

enum SCNPreviewGenerator {
    private static let device = MTLCreateSystemDefaultDevice()
    
    static func thumbnail(for scene: SCNScene, size: CGSize, time: TimeInterval = 0) async -> PlatformImage? {
        // Generation could not be performed when app is in background
        
#if os(iOS)
        let appIsActive = await MainActor.run {
            return UIApplication.shared.applicationState == .active
        }
#elseif os(macOS)
        let appIsActive = true
#endif
        
        guard let device, appIsActive else { return nil }
        
        let renderer = SCNRenderer(device: device, options: [:])
        renderer.autoenablesDefaultLighting = true
        renderer.scene = scene

        return renderer.snapshot(atTime: time, with: size, antialiasingMode: .multisampling4X)
    }
    
    static func thumbnail(for scene: SCNScene, size: CGSize, time: TimeInterval = 0) -> PlatformImage? {
        guard let device else { return nil }
        
        let renderer = SCNRenderer(device: device, options: [:])
        renderer.autoenablesDefaultLighting = true
        renderer.scene = scene

        return renderer.snapshot(atTime: time, with: size, antialiasingMode: .multisampling4X)
    }
}
