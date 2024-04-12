//
//  FolderGalleryItemViewModel.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-11.
//

import Foundation

class FolderGalleryItemViewModel {
    let url: URL
    let contentLoader: ContentPreviewLoader
    
    init(with url: URL, contentLoader: ContentPreviewLoader) {
        self.url = url
        self.contentLoader = contentLoader
    }
    
    var title: String {
        url.lastPathComponent
    }
    
    func loadContentPreview(_ completion: @escaping ContentPreviewLoader.Handler) {
        contentLoader.loadPreview(for: url, handler: completion)
    }
}
