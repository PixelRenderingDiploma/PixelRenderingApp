//
//  DepthStencilStateLibrary.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

enum DepthStencilStateType {
    case less
}

class DepthStencilStateLibrary: Library<DepthStencilStateType, MTLDepthStencilState> {
    var library: [DepthStencilStateType: DepthStencilState] = [:]
    
    override func fillLibrary() {
        library.updateValue(LessDepthStencilState(), forKey: .less)
    }
    
    override subscript(_ type: DepthStencilStateType) -> MTLDepthStencilState? {
        library[type]?.depthStencilState
    }
}

protocol DepthStencilState {
    var depthStencilState: MTLDepthStencilState { get }
}

class LessDepthStencilState: DepthStencilState {
    var depthStencilState: MTLDepthStencilState
    
    init() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = Engine.shared.device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }
}
