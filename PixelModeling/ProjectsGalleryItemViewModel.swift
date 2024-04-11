//
//  ProjectsGalleryItemViewModel.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-30.
//

import Foundation

class ProjectsGalleryItemViewModel {
    private var contentLoader: ContentPreviewLoader
    private var folderManager: ProjectFolderManager
    private var overridedModelURL: URL?
    
    init(with folderManager: ProjectFolderManager, overridedModelURL: URL?, contentLoader: ContentPreviewLoader) {
        self.folderManager = folderManager
        self.overridedModelURL = overridedModelURL
        self.contentLoader = contentLoader
    }
    
    var id: UUID {
        folderManager.id
    }
    
    var title: String {
        folderManager.id.uuidString.lowercased()
    }
    
    func loadModelPreview(_ completion: @escaping ContentPreviewLoader.Handler) {
        let url = overridedModelURL ?? folderManager.defaultModelURL
        contentLoader.loadPreview(for: url, handler: completion)
    }
    
    func loadContentPreview(_ completion: @escaping ContentPreviewLoader.Handler) {
        guard let url = getContentPreviewUrl() else {
            return completion(.failure(URLError(.fileDoesNotExist)))
        }
        
        contentLoader.loadPreview(for: url, handler: completion)
    }
    
    func getContentPreviewUrl() -> URL? {
        folderManager.videos.first ?? folderManager.images.first
    }
    
    func getVideoURL() -> URL? {
        folderManager.videos.first
    }
}
