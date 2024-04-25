//
//  ProjectsGalleryItemViewModel.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-30.
//

import Foundation

class ProjectsGalleryItemViewModel {
    let folderManager: ProjectFolderManager
    let overridedModelURL: URL?
    
    private let contentLoader: ContentPreviewLoader
    
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
    
    var modelURL: URL {
        overridedModelURL ?? folderManager.defaultModelURL
    }
    
    func loadModelPreview(_ completion: @escaping ContentPreviewLoader.Handler) {
        contentLoader.loadPreview(for: modelURL, handler: completion)
    }
    
    func loadContentPreview(_ completion: @escaping ContentPreviewLoader.Handler) {
        guard let url = getContentPreviewUrl() else {
            return completion(.failure(URLError(.fileDoesNotExist)))
        }
        
        contentLoader.loadPreview(for: url, handler: completion)
    }
    
    func getContentPreviewUrl() -> URL? {
        folderManager.videos.filter { !$0.isPlaceholder }.first ?? folderManager.images.filter { !$0.isPlaceholder }.first
    }
    
    func getVideoURL() -> URL? {
        folderManager.videos.first
    }
}
