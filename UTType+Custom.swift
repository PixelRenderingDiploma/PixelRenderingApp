//
//  UTType+Custom.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-03.
//

import UniformTypeIdentifiers

extension UTType {
    static var glb: UTType {
        UTType(filenameExtension: "glb") ?? UTType(mimeType: "model/gltf-binary", conformingTo: .threeDContent) ?? UTType(importedAs: "com.hlebushek.glb")
    }
    
    static var obj: UTType {
        UTType(filenameExtension: "obj")!
    }
}
