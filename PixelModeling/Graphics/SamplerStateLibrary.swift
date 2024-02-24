//
//  SamplerStateLibrary.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import MetalKit

enum SamplerStateType {
    case none
    case linear
}

class SamplerStateLibrary: Library<SamplerStateType, MTLSamplerState> {
    var library: [SamplerStateType : SamplerState] = [:]
    
    override func fillLibrary() {
        library.updateValue(LinearSamplerState(), forKey: .linear)
    }
    
    override subscript(_ type: SamplerStateType) -> MTLSamplerState? {
        library[type]?.samplerState
    }
}

protocol SamplerState {
    var name: String { get }
    var samplerState: MTLSamplerState { get }
}

class LinearSamplerState: SamplerState {
    var name: String = "Linear Sampler State"
    var samplerState: MTLSamplerState
    
    init() {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.lodMinClamp = 0
        samplerDescriptor.label = name
        samplerState = Engine.shared.device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
