//
//  ImageAspectView.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-10.
//

import AppKit

class ImageAspectView: NSImageView {
    var aspect: CALayerContentsGravity = .resize {
        didSet {
            imageLayer.contentsGravity = aspect
        }
    }
    
    private let imageLayer = CALayer()
    
    private func commonInit() {
        self.wantsLayer = true
        self.layer = imageLayer
        self.layer?.contentsGravity = aspect
        self.wantsLayer = true
        self.clipsToBounds = true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override var image: NSImage? {
        set {
            self.layer?.contentsGravity = aspect
            self.layer?.contents = newValue
        }
        
        get {
            return self.layer?.contents as? NSImage
        }
    }
}
