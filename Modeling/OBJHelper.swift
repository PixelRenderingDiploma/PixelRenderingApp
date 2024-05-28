//
//  OBJHelper.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-22.
//

import Foundation

class OBJHelper {
    func export(primitive: Primitive, to url: URL) {
        let vertices = primitive.vertices
        let indices = primitive.indices
        
        var objContent = ""
        
        for vertex in vertices {
            objContent += "v \(vertex.position.x) \(vertex.position.y) \(vertex.position.z)\n"
            objContent += "vt \(vertex.texture.x) \(vertex.texture.y)\n"
            objContent += "vn \(vertex.normal.x) \(vertex.normal.y) \(vertex.normal.z)\n"
        }
        
        if indices.isEmpty {
            for i in 1...vertices.count {
                if i % 3 == 0 { objContent += "f" }
                objContent += " \(i)/\(i)/\(i)"
                if i % 3 == 0 { objContent += "\n" }
            }
        } else {
            for i in 0..<indices.count {
                if i % 3 == 0 {
                    objContent += "\nf"
                }
                
                let idx = indices[i] + 1
                objContent += " \(idx)/\(idx)/\(idx)"
            }
        }
    
        if let data = objContent.data(using: .utf8) {
            do {
                try data.write(to: url)
                print("File saved successfully to \(url.path())")
            } catch {
                print("Failed to save file: \(error)")
            }
        }
    }
}
