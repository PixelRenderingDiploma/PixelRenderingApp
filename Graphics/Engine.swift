//
//  Engine.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

class Engine {
    static var shared = Engine()
    
    private(set) var device: MTLDevice!
    private(set) var commandQueue: MTLCommandQueue!
    private(set) var defaultLibrary: MTLLibrary!
    
    func start(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        self.defaultLibrary = device.makeDefaultLibrary()
    }
}

class Preferences {
    static var clearColor: MTLClearColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.8, alpha: 1)
    static var mainPixelFormat: MTLPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
    static var mainDepthPixelFormat: MTLPixelFormat = MTLPixelFormat.depth32Float
}
