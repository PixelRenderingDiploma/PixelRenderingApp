//
//  VideoDetailedViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-30.
//

import Cocoa
import AVKit

class VideoDetailedViewController: NSViewController {
    @IBOutlet weak var playerView: AVPlayerView?
    var player: AVPlayer?
    
    var url: URL?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        reload()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        playerView?.player?.pause()
        playerView?.player = nil
    }
    
    func update(with url: URL) {
        self.url = url
    }
    
    func reload() {
        guard let url else {
            return
        }
        
        player = AVPlayer(url: url)
        
        playerView?.player?.pause()
        playerView?.player = player
        playerView?.player?.play()
    }
}
