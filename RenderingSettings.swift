//
//  RenderingSettings.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-03.
//

import Foundation

struct RenderingSettings: Codable {
    let type: RenderingType
    let flyby: CameraFlyby
    let scene_effect: SceneEffect
    let post_effect: PostEffect
    
    let duration: Int
    let start_frame: Int // Start frame for video. Rendering frame for image.
}

enum RenderingType: Int, CaseIterable, Codable {
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

enum CameraFlyby: Int, CaseIterable, Codable {
    case circleHorizontal
    case circleVertical
}

enum SceneEffect: Int, CaseIterable, Codable {
    case empty
    case breaking
    case liquidPuring
    
    var title: String {
        switch self {
        case .empty:
            "None"
        case .breaking:
            "Breaking"
        case .liquidPuring:
            "Liquid Puring"
        }
    }
}

enum PostEffect: Int, CaseIterable, Codable {
    case empty
    case pixelization
    
    var title: String {
        switch self {
        case .empty:
            "None"
        case .pixelization:
            "Pixelization"
        }
    }
}
