//
//  FolderGalleryImageCollectionViewItem.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-19.
//

import Cocoa

class FolderGalleryImageCollectionViewItem: NSCollectionViewItem {
    enum Constants {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier("FolderGalleryImageCollectionViewItem")
    }
    
    private var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.imageView as? ImageAspectView)?.aspect = .resizeAspectFill
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
        self.textField?.stringValue = url.lastPathComponent
        self.textField?.toolTip = url.lastPathComponent
    }
}
