//
//  ProjectsGalleryImageCollectionViewItem.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-19.
//

import Cocoa

class ProjectsGalleryImageCollectionViewItem: NSCollectionViewItem {
    enum Constants {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier("ProjectsGalleryImageCollectionViewItem")
    }
    
    private var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }
    
    func update(with url: URL) {
        self.url = url
        reload()
    }
    
    private func reload() {
        guard let url else {
            return
        }
        
        self.imageView?.image = PlatformImage(contentsOfFile: url.path())
    }
    
}
