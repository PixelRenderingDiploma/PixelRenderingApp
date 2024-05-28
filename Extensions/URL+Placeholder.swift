//
//  URL+Placeholder.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-08.
//

import Foundation

extension URL {
    var isPlaceholder: Bool {
        let attributes = try? FileManager.default.attributesOfItem(atPath: self.path())
        let size = (attributes?[.size] as? NSNumber) ?? 0
        
        return size == 0
    }
}
