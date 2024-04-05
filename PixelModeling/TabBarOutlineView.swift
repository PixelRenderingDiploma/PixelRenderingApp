//
//  TabBarOutlineView.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-31.
//

import Cocoa

class TabBarOutlineView: NSOutlineView {
    override func menu(for event: NSEvent) -> NSMenu? {
        let point = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        let item = self.item(atRow: row)

        guard let item else {
            return nil
        }

        return (self.delegate as? MenuOutlineViewDelegate)?.outlineView(self, menuFor: item)
    }
}
