//
//  RendererPreviewViewModel.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-30.
//

import Foundation

class RendererPreviewViewModel {
    private(set) var storageItem: StorageItem?
    private var folderManager: ProjectFolderManager
    private var webApi: WebApi?
    
    init(with storageItem: StorageItem?, folderManager: ProjectFolderManager, webApi: WebApi?) {
        self.storageItem = storageItem
        self.folderManager = folderManager
        self.webApi = webApi
    }
    
    func loadVideo() async throws -> URL? {
        guard let id = storageItem?.id else {
            return nil
        }
        
        if let url = folderManager.video(with: id) {
            return url
        }
        
        let idStr = id.uuidString.lowercased()
        let mediaURL = URL(fileURLWithPath: "renders/videos/" + idStr).appendingPathExtension(for: .mpeg4Movie)
        
        let data = try await webApi?.getUserBlob(blobPath: mediaURL.path())
        
        let folder = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let url = folder.appending(path: mediaURL.path())
        
        try FileManager.default.createFile(atPath: url.path(), contents: data, withIntermediateDirectories: true)
        
        return url
    }
    
    var title: String {
        storageItem?.id.uuidString.lowercased() ?? ""
    }
}
