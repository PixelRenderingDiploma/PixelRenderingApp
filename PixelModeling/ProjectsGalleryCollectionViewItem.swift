//
//  ProjectsGalleryCollectionViewItem.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-27.
//

import Cocoa

protocol ProjectsGalleryCollectionViewItemDelegate: AnyObject {
    func didUserRequestRenderItem(with id: UUID)
    func didUserDeleteItem(with id: UUID, cloud: Bool)
    
    func didUserSyncProject(with id: UUID)
}

class ProjectsGalleryCollectionViewItem: NSCollectionViewItem {
    enum Constants {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier("ProjectsGalleryCollectionViewItem")
    }
    
    @IBOutlet weak var renderedContentView: NSView?
    
    @IBOutlet weak var previewImageView: NSImageView?
    @IBOutlet weak var nameLabel: NSTextField?
    
    @IBOutlet weak var syncStatusButton: SymbolButton?
    @IBOutlet weak var optionsButton: NSButton?
    
    weak var delegate: ProjectsGalleryCollectionViewItemDelegate?
    var viewModel: ProjectsGalleryItemViewModel?
    
    private var renderedPreviewViewController: RendererPreviewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadRenderedContentPreview()
    }
    
    func reloadRenderedContentPreview() {
        renderedPreviewViewController?.view.removeFromSuperview()
        
        guard let viewModel else {
            return
        }
        
        nameLabel?.stringValue = viewModel.title
        viewModel.loadModelPreview { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let image):
                    self?.previewImageView?.image = image
                case .failure:
                    let warning = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
                    self?.previewImageView?.image = warning
                }
            }
        }
        
        let viewController = RendererPreviewViewController(with: viewModel)
        renderedPreviewViewController = viewController
        renderedContentView?.addSubview(viewController.view)
        
        viewController.view.autoresizingMask = [.width, .height]
        viewController.view.frame = renderedContentView?.bounds ?? .zero
    }
    
    func update(with viewModel: ProjectsGalleryItemViewModel) {
        self.viewModel = viewModel
        self.reloadRenderedContentPreview()
    }
    
    func update(with status: SyncStatus) {
        switch status {
        case .syncing:
            syncStatusButton?.symbolImageView?.addSymbolEffect(.bounce, options: .repeating)
            syncStatusButton?.isEnabled = false
        case .synced:
            syncStatusButton?.symbolImageView?.removeAllSymbolEffects()
            syncStatusButton?.isEnabled = false
        case .local, .cloud, .cloudContent:
            syncStatusButton?.symbolImageView?.removeAllSymbolEffects()
            syncStatusButton?.isEnabled = true
        }
        
        syncStatusButton?.image = NSImage(systemSymbolName: status.systemSymbolName, accessibilityDescription: nil)
    }
    
    @IBAction func syncButtonAction(_ sender: Any) {
        update(with: .syncing)
        viewModel.map { delegate?.didUserSyncProject(with: $0.id) }
    }
    
    @IBAction func onOptionsButtonAction(_ sender: Any) {
        guard let optionsButton, let event = NSApp.currentEvent else {
            return
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Render", action: #selector(didSelectRequestRenderItem), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(didSelectDeleteItem), keyEquivalent: ""))
        
        NSMenu.popUpContextMenu(menu, with: event, for: optionsButton, with: nil)
    }
    
    @objc
    private func didSelectRequestRenderItem(_ sender: Any) {
        viewModel.map { delegate?.didUserRequestRenderItem(with: $0.id) }
    }
    
    @objc
    private func didSelectDeleteItem(_ sender: Any) {
        guard let id = viewModel?.id else { return }
        
        let alert = NSAlert()
        alert.messageText = "Delete Project"
        alert.informativeText = "Are you shure you want to delete project"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        alert.buttons.first?.bezelColor = .red
        
        let accessoryView = NSView()
        let btn = NSButton(checkboxWithTitle: "Delete on Cloud", target: self, action: nil)
        
        accessoryView.addSubview(btn)
        accessoryView.frame = CGRect(x: 0, y: 0, width: 200, height: 8)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = NSLayoutConstraint(item: btn, attribute: .centerX, relatedBy: .equal, toItem: accessoryView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: btn, attribute: .centerY, relatedBy: .equal, toItem: accessoryView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        
        alert.accessoryView = accessoryView
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn:
            delegate?.didUserDeleteItem(with: id, cloud: btn.state == .on)
        default:
            break
        }
    }
}

extension ProjectsGalleryCollectionViewItem: SubSelectionCollectionViewItem {
    func subitemIndex(at point: NSPoint) -> Int? {
        if let view = renderedContentView, view.bounds.contains(view.convert(point, from: self.view)) {
            return 1
        } else if let view = previewImageView, view.bounds.contains(point) {
            return 0
        }
            
        return nil
    }
    
    func object(for selection: Int) -> Any? {
        switch selection {
        case 1:
            viewModel?.folderManager.videosFolder
        case 0:
            viewModel?.modelURL
        default:
            nil
        }
    }
    
    func select() {}
}
