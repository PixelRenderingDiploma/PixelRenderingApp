//
//  ThreeDModel.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-20.
//

import Foundation
import SwiftCSV

class ThreeDModel {
    var vertices: [PMVertex]
    var indices: [Int]
    
    init(vertices: [PMVertex], indices: [Int] = []) {
        self.vertices = vertices
        self.indices = indices
    }
}

enum BasicShape: Int, CaseIterable {
    case cube
    case sphere
    case cone
    case piramid
    
    var title: String {
        switch self {
        case .cube:
            "cube"
        case .sphere:
            "sphere"
        case .cone:
            "cone"
        case .piramid:
            "piramid"
        }
    }
}

class ThreeDModelFactory {
    func threeDModel(for shape: BasicShape) -> ThreeDModel? {
        guard let url = Bundle.main.url(forResource: shape.title.capitalized, withExtension: "csv"),
              let csv = try? CSV<Named>(url: url, delimiter: .comma, encoding: .utf8, loadColumns: true) else {
            return nil
        }
        
        var vertices: [PMVertex] = []
        
        csv.rows.forEach { row in
            let position    = simd_float3(parseCSVRow(row, keys: ["px", "py", "pz"]))
            let color       = simd_float4(parseCSVRow(row, keys: ["cr", "cg", "cb", "ca"]))
            let texture     = simd_float2(parseCSVRow(row, keys: ["tu", "tv"]))
            let normal      = simd_float3(parseCSVRow(row, keys: ["nx", "ny", "nz"]))
            let tangent     = simd_float3(parseCSVRow(row, keys: ["tx", "ty", "tz"]))
            let bitangent   = simd_float3(parseCSVRow(row, keys: ["bx", "by", "bz"]))
            
            let vertex = PMVertex(position: position, color: color, texture: texture, normal: normal, tangent: tangent, bitangent: bitangent)
            vertices.append(vertex)
        }
        
        return ThreeDModel(vertices: vertices)
    }
}


func parseCSVRow<T: LosslessStringConvertible>(_ row: [String: String], keys: [String]) -> [T] {
    return keys.compactMap { T(row[$0] ?? "") }
}
