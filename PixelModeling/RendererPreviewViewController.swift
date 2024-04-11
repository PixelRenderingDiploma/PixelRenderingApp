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
    @IBOutlet weak var playerView: AVPlayerView?
    
    var queuePlayer: AVQueuePlayer?
    var playerLooper: AVPlayerLooper?
    
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
        
        let trackingArea = NSTrackingArea(rect: playerView?.bounds ?? .zero, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
        playerView?.addTrackingArea(trackingArea)
        
        imageView?.aspect = .resizeAspectFill
        imageView?.clipsToBounds = true
        reload()
    }
    
    func reload() {
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
    }
    
    func startVideo() {
        guard let url = viewModel?.getVideoURL() else {
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.queuePlayer = queuePlayer
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        self.playerView?.player = queuePlayer
        
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.queuePlayer?.play()
                    self.showView(for: .video)
                default:
                    break
                }
            }
            .store(in: &subscriptions)
    }
    
    func stopVideo() {
        showView(for: .image)
        
        self.subscriptions.removeAll()
        self.queuePlayer?.removeAllItems()
        self.playerLooper = nil
        self.playerView?.player = nil
        self.queuePlayer = nil
    }
    
    private func showView(for type: UTType) {
        let isVideo = type.conforms(to: .mpeg4Movie) || type.conforms(to: .video)
        
        imageView?.isHidden = isVideo
        playerView?.alphaValue = isVideo ? 1 : 0
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        startVideo()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        stopVideo()
    }
}
