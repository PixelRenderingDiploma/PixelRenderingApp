//
//  MenuOutlineViewDelegate.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-04.
//

import Cocoa

protocol MenuOutlineViewDelegate: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, menuFor item: Any) -> NSMenu?
}
