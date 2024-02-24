//
//  NibLoadable.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-29.
//

import AppKit

protocol NibLoadable: AnyObject {
    static var reusableItemNibName: String { get }
}

extension NibLoadable where Self: NSViewController {
    static var reusableItemNibName: String {
        self.className().components(separatedBy: ".").last!
    }
}
