//
//  FolderGalleryViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-19.
//

import Cocoa
import UniformTypeIdentifiers

class FolderGalleryViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView?
    
    var url: URL? {
        didSet {
            guard let url,
                  let content = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]) else {
                return
            }
            
            items = content
            collectionView?.reloadData()
        }
    }
    
    private var items: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.isSelectable = true
        collectionView?.allowsMultipleSelection = false
        
        collectionView?.register(ProjectsGalleryImageCollectionViewItem.self, forItemWithIdentifier: ProjectsGalleryImageCollectionViewItem.Constants.reuseIdentifier)
        collectionView?.register(ProjectsGalleryVideoCollectionViewItem.self, forItemWithIdentifier: ProjectsGalleryVideoCollectionViewItem.Constants.reuseIdentifier)
    }
}

extension FolderGalleryViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let url = items[indexPath.item]
        let type = UTType(filenameExtension: url.pathExtension)
        
        let viewItem: NSCollectionViewItem?
        
        if let type, type.conforms(to: .mpeg4Movie) {
            viewItem = collectionView.makeItem(withIdentifier: ProjectsGalleryVideoCollectionViewItem.Constants.reuseIdentifier, for: indexPath)
            (viewItem as? ProjectsGalleryVideoCollectionViewItem)?.update(with: url)
        } else if let type, type.conforms(to: .image) {
            viewItem = collectionView.makeItem(withIdentifier: ProjectsGalleryImageCollectionViewItem.Constants.reuseIdentifier, for: indexPath)
            (viewItem as? ProjectsGalleryImageCollectionViewItem)?.update(with: url)
        } else {
            viewItem = nil
        }
        
        return viewItem ?? NSCollectionViewItem()
    }
}
