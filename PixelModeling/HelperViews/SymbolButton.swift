//
//  SymbolButton.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-14.
//

import Cocoa

class SymbolButton: NSButton {
    private(set) var symbolImageView: NSImageView?
    private var imageViewInset = CGPoint(x: 5, y: 5)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        let imageView = NSImageView(frame: bounds.insetBy(dx: imageViewInset.x, dy: imageViewInset.y))
        imageView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(imageView)
        
        symbolImageView = imageView
    }
    
    override func layout() {
        super.layout()
        symbolImageView?.frame = bounds.insetBy(dx: imageViewInset.x, dy: imageViewInset.y)
    }
    
    override var title: String {
        set {}
        get { "" }
    }
    
    override var image: NSImage? {
        get {
            symbolImageView?.image
        }
        
        set {
            symbolImageView?.image = newValue
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            symbolImageView?.isEnabled = isEnabled
        }
    }
}
