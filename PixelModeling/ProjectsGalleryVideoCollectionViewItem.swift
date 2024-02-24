//
//  ProjectsGalleryVideoCollectionViewItem.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-19.
//

import Cocoa
import AVKit

class ProjectsGalleryVideoCollectionViewItem: NSCollectionViewItem {
    enum Constants {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier("ProjectsGalleryVideoCollectionViewItem")
    }
    
    @IBOutlet weak var playerView: AVPlayerView?
    var queuePlayer: AVQueuePlayer?
    var playerLooper: AVPlayerLooper?
    
    private var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }
    
    func update(with url: URL) {
        self.url = url
        reload()
    }
    
    private func reload() {
        guard let url else {
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.queuePlayer = queuePlayer
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        self.playerView?.player = queuePlayer
        self.queuePlayer?.play()
    }
}
