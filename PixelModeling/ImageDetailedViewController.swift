//
//  ImageDetailedViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-08.
//

import QuartzCore

class ImageDetailedViewController: PlatformViewController {
    @IBOutlet weak var imageView: PlatformImageView?
    
    private(set) var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.wantsLayer = true
        imageView?.layer?.contentsGravity = .resizeAspect
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        reload()
    }
    
    func update(with url: URL) {
        self.url = url
    }
    
    func reload() {
        guard let url else {
            return
        }
        
        imageView?.layer?.contents = PlatformImage(contentsOf: url)
    }
}
