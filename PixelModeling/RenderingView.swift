//
//  RenderingView.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-20.
//

import MetalKit

class RenderingView: MTKView {
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.clearColor = Preferences.clearColor
        self.colorPixelFormat = Preferences.mainPixelFormat
        self.depthStencilPixelFormat = Preferences.mainDepthPixelFormat
    }
}
