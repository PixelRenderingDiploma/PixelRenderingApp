//
//  VideoPreviewViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-11.
//

import AVKit

class PreviewPlayerView: AVPlayerView {
    var queuePlayer: AVQueuePlayer?
    var playerLooper: AVPlayerLooper?
    
    private var url: URL?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupTrackingArea()
    }
    
    private func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.activeInActiveApp, .mouseEnteredAndExited, .inVisibleRect]
        let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.trackingAreas.forEach { self.removeTrackingArea($0) }
        setupTrackingArea()
    }
    
    override func mouseEntered(with event: NSEvent) {
        startVideo()
    }
    
    override func mouseExited(with event: NSEvent) {
        stopVideo()
    }
    
    func update(with url: URL) {
        self.url = url
        
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.queuePlayer = queuePlayer
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.player = queuePlayer
    }
    
    func startVideo() {
        guard let url, let queuePlayer else {
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.replaceCurrentItem(with: playerItem)
        queuePlayer.play()
    }
    
    func stopVideo() {
        self.queuePlayer?.pause()
        self.queuePlayer?.removeAllItems()
        self.playerLooper = nil
    }
}
