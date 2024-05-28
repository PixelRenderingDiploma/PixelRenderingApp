//
//  UserInterectionDisabledView.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-22.
//

import Cocoa

class UserInterectionDisabledView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }
    
    private func commonInit() {
        self.wantsLayer = true
//        self.layer?.backgroundColor = NSColor.clear.cgColor
//        self.layer?.cornerRadius = 8
    }
}
