//
//  ProjectsGalleryViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-27.
//

import AppKit
import SceneKit
import GLTFSceneKit

class ProjectsGalleryViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView?
    
    @Service private var storageManager: StorageManagerProtocol
    
    private var items: [StorageItem] = []
    private lazy var operationQueue: OperationQueue = {
        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 1
        opQueue.qualityOfService = .utility
        return opQueue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.isSelectable = true
        collectionView?.allowsMultipleSelection = false
        
        collectionView?.register(ProjectsGalleryCollectionViewItem.self, forItemWithIdentifier: ProjectsGalleryCollectionViewItem.Constants.reuseIdentifier)
        
        DispatchQueue.main.async { [weak self] in
            self?.reload()
        }
    }
    
    func reload() {
        items = storageManager.getAll()
        collectionView?.reloadData()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ThreeDModelDetailedSegue":
            guard let indexPath = sender as? IndexPath else { return }
            
            let selectedItem = items[indexPath.item]
            
            if let destinationVC = segue.destinationController as? ThreeDModelDetailedViewController {
                destinationVC.update(with: selectedItem)
            }
        case "PlayerDetailedSegue":
            guard let id = sender as? UUID else { return }
            if let destinationVC = segue.destinationController as? VideoDetailedViewController,
               let url = ProjectFolderManager(with: id)?.video(with: id) {
                destinationVC.update(with: url)
            }
        case "UploadSheetSegue":
            guard let id = sender as? UUID else { return }
            if let destinationVC = segue.destinationController as? RenderingRequestViewController {
                destinationVC.id = id
            }
        default:
            break
        }
    }
}

extension ProjectsGalleryViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let viewItem = collectionView.makeItem(withIdentifier: ProjectsGalleryCollectionViewItem.Constants.reuseIdentifier, for: indexPath)
        
        if let galleryViewItem = viewItem as? ProjectsGalleryCollectionViewItem, indexPath.item < items.count {
            galleryViewItem.delegate = self
            
            let item = items[indexPath.item]
            galleryViewItem.update(with: item)
            
            operationQueue.addOperation {
                var isStale = false
                guard let url = try? URL(resolvingBookmarkData: item.bookmark, bookmarkDataIsStale: &isStale) else {
                    return
                }
                
                guard let data = try? Data(contentsOf: url) else {
                    return
                }
                
                let scneneSource = GLTFSceneSource(data: data)
                
                do {
                    let scene = try scneneSource.scene(options: nil)
                    
                    let image = SCNPreviewGenerator.thumbnail(for: scene, size: CGSize(width: 512, height: 512))
                    
                    DispatchQueue.main.async {
                        galleryViewItem.update(with: image)
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        return viewItem
    }
}

extension ProjectsGalleryViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        performSegue(withIdentifier: "ThreeDModelDetailedSegue", sender: indexPaths.first)
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        return false
    }
}

extension ProjectsGalleryViewController: ProjectsGalleryCollectionViewItemDelegate {
    func didUserUploadItem(with id: UUID) {
        guard let item = storageManager.get(with: id) else {
            return
        }
        
        performSegue(withIdentifier: "UploadSheetSegue", sender: id)
    }
    
    func didUserDeleteItem(with id: UUID) {
        items.removeAll(where: { $0.id == id })
        storageManager.delete(with: id)
        
        collectionView?.reloadData()
    }
    
    func didUserSelectVideo(with id: UUID) {
        performSegue(withIdentifier: "PlayerDetailedSegue", sender: id)
    }
}
