//
//  NSImage+Thumbnail.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-09.
//

import AppKit

extension NSImage {
    func preparingThumbnail(maxWidth: CGFloat) -> NSImage? {
        let aspectRatio = size.width / size.height
        let thumbSize = NSSize(width: maxWidth, height: maxWidth / aspectRatio)

        let outputImage = NSImage(size: thumbSize)

        outputImage.lockFocus()
        
        draw(in: NSRect(x: 0, y: 0, width: thumbSize.width, height: thumbSize.height),
             from: NSRect(x: 0, y: 0, width: size.width, height: size.height),
             operation: .copy,
             fraction: 1.0)

        outputImage.unlockFocus()

        return outputImage
    }
}
