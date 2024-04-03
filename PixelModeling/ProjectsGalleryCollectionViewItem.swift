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
    
    @IBOutlet weak var optionsButton: NSButton?
    
    private var item: StorageItem?
    private var folderManager: ProjectFolderManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadRenderedContentPreview()
    }
    
    func reloadRenderedContentPreview() {
        renderedPreviewViewController?.view.removeFromSuperview()
        
        guard let item, let folderManager else {
            return
        }
        
        let viewModel = RendererPreviewViewModel(with: item, folderManager: folderManager)
        let viewController = RendererPreviewViewController(with: viewModel)
        renderedPreviewViewController = viewController
        renderedContentView?.addSubview(viewController.view)
        
        viewController.view.autoresizingMask = [.width, .height]
        viewController.view.frame = renderedContentView?.bounds ?? .zero
        
        let videoTapGesutre = PlatformTapGestureRecognizer(target: self, action: #selector(didSelectVideoItem))
        viewController.view.addGestureRecognizer(videoTapGesutre)
    }
    
    func update(with item: StorageItem) {
        self.item = item
        self.folderManager = ProjectFolderManager(with: item.id)
        
        self.nameLabel?.stringValue = item.name
        
        reloadRenderedContentPreview()
    }
    
    func update(with image: PlatformImage?) {
        self.previewImageView?.image = image
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
        guard let id = item?.id else { return }
        delegate?.didUserUploadItem(with: id)
    }
    
    @objc
    private func didSelectDeleteItem(_ sender: Any) {
        guard let id = item?.id else { return }
        delegate?.didUserDeleteItem(with: id)
    }
    
    @objc
    private func didSelectVideoItem(_ sender: Any) {
        guard let id = item?.id else { return }
        delegate?.didUserSelectVideo(with: id)
    }
}
