//
//  FolderGalleryVideoCollectionViewItem.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-19.
//

import Cocoa
import AVKit
import Combine

class FolderGalleryVideoCollectionViewItem: NSCollectionViewItem {
    enum Constants {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier("FolderGalleryVideoCollectionViewItem")
    }
    
    @IBOutlet weak var playerView: PreviewPlayerView?
    
    var viewModel: FolderGalleryItemViewModel?
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.imageView as? ImageAspectView)?.aspect = .resizeAspectFill
        playerView?.videoGravity = .resizeAspectFill
        reload()
    }
    
    func update(with viewModel: FolderGalleryItemViewModel) {
        self.viewModel = viewModel
        self.reload()
    }
    
    private func reload() {
        guard let viewModel else {
            return
        }
        
        viewModel.loadContentPreview { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let image):
                    self?.imageView?.image = image
                case .failure(let error):
                    break
                }
            }
        }
        
        subscriptions.removeAll()
        playerView?.update(with: viewModel.url)
        playerView?.player?.publisher(for: \.timeControlStatus)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .playing:
                    showView(for: .video)
                case .paused:
                    showView(for: .image)
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        self.textField?.stringValue = viewModel.title
        self.textField?.toolTip = viewModel.title
    }
    
    private func showView(for type: UTType) {
        let isVideo = type.conforms(to: .mpeg4Movie) || type.conforms(to: .video)
        
        imageView?.isHidden = isVideo
        playerView?.alphaValue = isVideo ? 1 : 0
    }
}
