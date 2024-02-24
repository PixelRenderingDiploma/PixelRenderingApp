//
//  RendererPreviewViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-29.
//

import Cocoa
import AVKit

class RendererPreviewViewController: NSViewController, NibLoadable {
    @IBOutlet weak var playerView: AVPlayerView?
    var queuePlayer: AVQueuePlayer?
    var playerLooper: AVPlayerLooper?
    
    var viewModel: RendererPreviewViewModel
    
    init(with viewModel: RendererPreviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: Self.reusableItemNibName, bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            guard let url = try await self.viewModel.loadVideo() else {
                return
            }
            
            let playerItem = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(playerItem: playerItem)
            self.queuePlayer = queuePlayer
            self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            
            Task { @MainActor in
                self.playerView?.player = queuePlayer
                self.queuePlayer?.play()
            }
        }
    }
}
