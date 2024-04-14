//
//  RenderingRequest.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-13.
//

import Foundation

struct RenderingRequest: Codable {
    let id: String
    let id_token: String
    let id_model: String
    let status: RenderingStatus
    let settings: RenderingSettings
}

extension RenderingRequest {
    static let empty = {
        RenderingRequest(id: "", id_token: "", id_model: "", status: .queue, settings: RenderingSettings(type: .image, flyby: .circleHorizontal, scene_effect: .empty, post_effect: .empty, duration: 0, start_frame: 0))
    }()
}

enum RenderingStatus: String, Codable {
    case queue
    case rendering
    case composing
    case error
    case done
}

extension RenderingStatus: SequenceFilter {
    typealias CaseType = RenderingStatus
    
    var isCompletionCase: Bool {
        switch self {
        case .done:
            true
        default:
            false
        }
    }
}
