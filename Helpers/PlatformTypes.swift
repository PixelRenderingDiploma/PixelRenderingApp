//
//  PlatformTypes.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-20.
//

#if os(iOS)
    import UIKit
    typealias PlatformViewController = UIViewController
    typealias PlatformView = UIView
    typealias PlatformButton = UIButton
    typealias PlatformColor = UIColor
    typealias PlatformImage = UIImage
    typealias PlatformImageView = UIImageView
    typealias PlatformTapGestureRecognizer = UITapGestureRecognizer
    typealias PlatformPanGestureRecognizer = UIPanGestureRecognizer
    typealias PlatformPinchGestureRecognizer = UIPinchGestureRecognizer
#elseif os(macOS)
    import AppKit
    typealias PlatformViewController = NSViewController
    typealias PlatformView = NSView
    typealias PlatformButton = NSButton
    typealias PlatformColor = NSColor
    typealias PlatformImage = NSImage
    typealias PlatformImageView = NSImageView
    typealias PlatformTapGestureRecognizer = NSClickGestureRecognizer
    typealias PlatformPanGestureRecognizer = NSPanGestureRecognizer
    typealias PlatformPinchGestureRecognizer = NSMagnificationGestureRecognizer

    extension NSMagnificationGestureRecognizer {
        var scale: CGFloat {
            self.magnification + 1.0
        }
    }
#endif
