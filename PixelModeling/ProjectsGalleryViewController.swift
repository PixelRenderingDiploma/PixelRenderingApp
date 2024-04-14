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
    @Service private var syncService: SyncService
    
    private let contentPreviewLoader = ContentPreviewLoader()
    
    private var items: [UUID] = []
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
        
        Task {
            try await observeProcessingContent()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.reload()
        }
    }
    
    func reload() {
        items = ProjectFolderManager.getProjects()
        collectionView?.reloadData()
    }
    
    private func observeProcessingContent() async throws {
        for await output in syncService.requestAggregator.updates {
            switch output.status {
            case .done, .error:
                guard let id = UUID(uuidString: output.id),
                      let idx = self.items.firstIndex(of: id) else {
                    return
                }
                
                self.collectionView?.reloadItems(at: [IndexPath(item: idx, section: 0)])
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ThreeDModelDetailedSegue":
            guard let indexPath = sender as? IndexPath else { return }
            
            let id = items[indexPath.item]
            
            if let destinationVC = segue.destinationController as? ThreeDModelDetailedViewController,
               let item = storageManager.get(with: id) {
                destinationVC.update(with: item)
            }
        case "PlayerDetailedSegue":
            guard let id = sender as? UUID else { return }
            if let destinationVC = segue.destinationController as? VideoDetailedViewController,
               let url = ProjectFolderManager(with: id)?.video(with: id) {
                destinationVC.update(with: url)
            }
        case "RenderRequestSheetSegue":
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
        let id = items[indexPath.item]
        let viewItem = collectionView.makeItem(withIdentifier: ProjectsGalleryCollectionViewItem.Constants.reuseIdentifier, for: indexPath)
        
        guard let galleryViewItem = viewItem as? ProjectsGalleryCollectionViewItem,
              let folderManager = ProjectFolderManager(with: id),
              let item = storageManager.get(with: id),
              indexPath.item < items.count else {
            return viewItem
        }
        
        let viewModel = ProjectsGalleryItemViewModel(
            with: folderManager,
            overridedModelURL: item.url,
            contentLoader: contentPreviewLoader)
        
        galleryViewItem.delegate = self
        galleryViewItem.update(with: viewModel)
        
        Task {
            let status = try? await syncService.syncStatus(for: item)
            status.map { galleryViewItem.update(with: $0) }
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
    func didUserRequestRenderItem(with id: UUID) {
        performSegue(withIdentifier: "RenderRequestSheetSegue", sender: id)
    }
    
    func didUserDeleteItem(with id: UUID, cloud: Bool) {
        Task {
            // TODO: Delete content but replace with placeholder and updated sync state
            if cloud {
                try? await syncService.delete(project: id)
            }
            
            ProjectFolderManager.delete(with: id)
            storageManager.delete(with: id)
            
            reload()
        }
    }
    
    func didUserSelectVideo(with id: UUID) {
        performSegue(withIdentifier: "PlayerDetailedSegue", sender: id)
    }
    
    func didUserSyncProject(with id: UUID) {
        Task {
            guard let item = storageManager.get(with: id),
                  let status = try? await syncService.syncStatus(for: item) else {
                return
            }
            
            switch status {
            case .local:
                try? syncService.createProject(with: id)
                await reload(item: id, afterSyncOf: [id])
            case .cloud:
                try? syncService.downloadProject(with: id)
                await reload(item: id, afterSyncOf: [id])
            case .cloudContent:
                guard let content = try? await syncService.syncProject(with: id) else {
                    break
                }
                
                NotificationCenter.default.post(name: .didSyncProject, object: nil, userInfo: ["id": id, "content": content])
                
                Task {
                    // Wait until all new content loaded
                    let ids = content
                        .values
                        .flatMap { $0 }
                        .compactMap { $0.split(separator: ".").first }
                        .compactMap { UUID(uuidString: String($0)) }
                    await reload(item: id, afterSyncOf: ids)
                }
            case .syncing, .synced:
                break
            }
        }
    }
    
    private func reload(item id: UUID, afterSyncOf ids: [UUID]) async {
        for id in ids {
            guard let updates = syncService.dataTransfer.updates(for: id) else {
                continue
            }
            
            for await _ in updates {}
        }
        
        guard let idx = self.items.firstIndex(of: id) else {
            return
        }
        
        self.collectionView?.reloadItems(at: [IndexPath(item: idx, section: 0)])
    }
}

extension Notification.Name {
     static let didSyncProject = Notification.Name("didSyncProject")
}
