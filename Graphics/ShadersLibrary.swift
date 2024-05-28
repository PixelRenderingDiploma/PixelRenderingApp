//
//  ShadersLibrary.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-13.
//

import AppKit

struct Shader {
    var function: MTLFunction
    
    init?(functionName: String) {
        guard let function = Engine.shared.defaultLibrary.makeFunction(name: functionName) else {
            return nil
        }
        
        self.function = function
        self.function.label = functionName
    }
}

enum ShaderType {
    case basic
    case basicFragment
    
    case instanced
}

class ShadersLibrary: Library<ShaderType, MTLFunction> {
    var library: [ShaderType : Shader] = [:]
    
    override func fillLibrary() {
        // Vertex Shaders
        guard let basicVertex = Shader(functionName: "basic_vertex_shader")/*,*/
              /*let instancedVertex = Shader(functionName: "instanced_vertex_shader")*/ else {
            return
        }
        
        library.updateValue(basicVertex, forKey: .basic)
//        library.updateValue(instancedVertex, forKey: .instanced)
        
        // Fragment Shaders
        guard let basicFragment = Shader(functionName: "basic_fragment_shader") else {
            return
        }
        
        library.updateValue(basicFragment, forKey: .basicFragment)
    }

    override subscript(_ type: ShaderType) -> MTLFunction? {
        return library[type]?.function
    }
}
