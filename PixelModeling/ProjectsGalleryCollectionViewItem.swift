//
//  ProjectsGalleryCollectionViewItem.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-27.
//

import Cocoa

protocol ProjectsGalleryCollectionViewItemDelegate: AnyObject {
    func didUserUploadItem(with id: UUID)
    func didUserDeleteItem(with id: UUID)
    func didUserSelectVideo(with id: UUID)
    
    func didUserSyncProject(with id: UUID)
}

class ProjectsGalleryCollectionViewItem: NSCollectionViewItem {
    enum Constants {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier("ProjectsGalleryCollectionViewItem")
    }
    
    weak var delegate: ProjectsGalleryCollectionViewItemDelegate?
    
    private var renderedPreviewViewController: RendererPreviewViewController?
    
    @IBOutlet weak var renderedContentView: NSView?
    
    @IBOutlet weak var previewImageView: NSImageView?
    @IBOutlet weak var nameLabel: NSTextField?
    
    @IBOutlet weak var syncStatusButton: NSButton?
    @IBOutlet weak var optionsButton: NSButton?
    
    private var folderManager: ProjectFolderManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadRenderedContentPreview()
    }
    
    func reloadRenderedContentPreview() {
        renderedPreviewViewController?.view.removeFromSuperview()
        
        guard let folderManager else {
            return
        }
        
        let viewModel = RendererPreviewViewModel(with: folderManager)
        let viewController = RendererPreviewViewController(with: viewModel)
        renderedPreviewViewController = viewController
        renderedContentView?.addSubview(viewController.view)
        
        viewController.view.autoresizingMask = [.width, .height]
        viewController.view.frame = renderedContentView?.bounds ?? .zero
        
        let videoTapGesutre = PlatformTapGestureRecognizer(target: self, action: #selector(didSelectVideoItem))
        viewController.view.addGestureRecognizer(videoTapGesutre)
    }
    
    func update(with item: StorageItem) {
        self.nameLabel?.stringValue = item.name
        
        update(with: item.id)
    }
    
    func update(with id: UUID) {
        self.folderManager = ProjectFolderManager(with: id)
        
        reloadRenderedContentPreview()
    }
    
    func update(with image: PlatformImage?) {
        self.previewImageView?.image = image
    }
    
    func update(with status: SyncStatus) {
        switch status {
        case .local, .cloud:
            syncStatusButton?.isEnabled = true
        case .synced:
            syncStatusButton?.isEnabled = false
        }
        
        syncStatusButton?.image = NSImage(systemSymbolName: status.systemSymbolName, accessibilityDescription: nil)
    }
    
    @IBAction func syncButtonAction(_ sender: Any) {
        guard let id = folderManager?.id else { return }
        delegate?.didUserSyncProject(with: id)
    }
    
    @IBAction func onOptionsButtonAction(_ sender: Any) {
        guard let optionsButton, let event = NSApp.currentEvent else {
            return
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Upload", action: #selector(didSelectUploadItem), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(didSelectDeleteItem), keyEquivalent: ""))
        
        NSMenu.popUpContextMenu(menu, with: event, for: optionsButton, with: nil)
    }
    
    @objc
    private func didSelectUploadItem(_ sender: Any) {
        guard let id = folderManager?.id else { return }
        delegate?.didUserUploadItem(with: id)
    }
    
    @objc
    private func didSelectDeleteItem(_ sender: Any) {
        guard let id = folderManager?.id else { return }
        delegate?.didUserDeleteItem(with: id)
    }
    
    @objc
    private func didSelectVideoItem(_ sender: Any) {
        guard let id = folderManager?.id else { return }
        delegate?.didUserSelectVideo(with: id)
    }
}
