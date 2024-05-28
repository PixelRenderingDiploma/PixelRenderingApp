//
//  FileManager+Intermediate.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-30.
//

import Foundation

extension FileManager {
    func createFile(atPath: String, contents: Data?, withIntermediateDirectories: Bool) throws {
        let fileURL = URL(filePath: atPath)
        try createDirectory(atPath: fileURL.deletingLastPathComponent().path(), withIntermediateDirectories: withIntermediateDirectories)
        createFile(atPath: atPath, contents: contents)
    }
}
