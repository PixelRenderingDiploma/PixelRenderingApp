//
//  RenderingSettings.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-03.
//

import Foundation

enum RenderingType: Int, CaseIterable {
    case image
    case video
    
    var title: String {
        switch self {
        case .image:
            "Image"
        case .video:
            "Video"
        }
    }
}
