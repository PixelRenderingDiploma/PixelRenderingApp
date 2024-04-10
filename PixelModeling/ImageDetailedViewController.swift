//
//  ImageDetailedViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-08.
//

import QuartzCore

class ImageDetailedViewController: PlatformViewController {
    @IBOutlet weak var imageView: ImageAspectView?
    
    private(set) var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.aspect = .resizeAspect
    }
    
    func update(with url: URL) {
        self.url = url
    }
    
    func reload() {
        guard let url,
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        imageView?.image = PlatformImage(data: data)
    }
}
