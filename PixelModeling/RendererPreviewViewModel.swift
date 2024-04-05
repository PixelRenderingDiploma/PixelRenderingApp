//
//  RendererPreviewViewModel.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-30.
//

import Foundation

class RendererPreviewViewModel {
    private var folderManager: ProjectFolderManager
    
    init(with folderManager: ProjectFolderManager) {
        self.folderManager = folderManager
    }
    
    func loadVideo() async throws -> URL? {
        return folderManager.video(with: folderManager.id)
        
//        let idStr = id.uuidString.lowercased()
//        let mediaURL = URL(fileURLWithPath: "renders/videos/" + idStr).appendingPathExtension(for: .mpeg4Movie)
//        
//        let data = try await webApi?.getUserBlob(blobPath: mediaURL.path())
//        
//        let folder = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let url = folder.appending(path: mediaURL.path())
//        
//        try FileManager.default.createFile(atPath: url.path(), contents: data, withIntermediateDirectories: true)
//        
//        return url
    }
    
    var title: String {
        folderManager.id.uuidString.lowercased()
    }
}
