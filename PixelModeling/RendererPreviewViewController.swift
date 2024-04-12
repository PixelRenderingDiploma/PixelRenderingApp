//
//  RendererPreviewViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-29.
//

import Cocoa
import AVKit
import Combine

class RendererPreviewViewController: NSViewController, NibLoadable {
    @IBOutlet weak var imageView: ImageAspectView?
    @IBOutlet weak var playerView: PreviewPlayerView?
    
    weak var viewModel: ProjectsGalleryItemViewModel?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(with viewModel: ProjectsGalleryItemViewModel) {
        self.viewModel = viewModel
        super.init(nibName: Self.reusableItemNibName, bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.aspect = .resizeAspectFill
        reload()
    }
    
    func reload() {
        subscriptions.removeAll()
        showView(for: .image)
        
        viewModel?.loadContentPreview { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let image):
                    self?.imageView?.image = image
                case .failure(let error):
                    if error is URLError {
                        self?.imageView?.image = NSImage(systemSymbolName: "photo.stack", accessibilityDescription: nil)
                    } else {
                        let warning = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
                        self?.imageView?.image = warning
                    }
                }
            }
        }
        
        viewModel?.getVideoURL().map { playerView?.update(with: $0) }
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
    }
    
    private func showView(for type: UTType) {
        let isVideo = type.conforms(to: .mpeg4Movie) || type.conforms(to: .video)
        
        imageView?.isHidden = isVideo
        playerView?.alphaValue = isVideo ? 1 : 0
    }
}
