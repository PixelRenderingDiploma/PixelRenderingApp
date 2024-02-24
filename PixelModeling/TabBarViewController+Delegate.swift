//
//  TabBarViewController+Delegate.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-31.
//

import Cocoa

extension TabBarViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        let node = TabBarViewController.node(from: item)
        return node?.isSpecialGroup ?? false
    }
    
    // What should be the row height of an outline view item?
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        var rowHeight = outlineView.rowHeight
        
        guard let node = TabBarViewController.node(from: item) else { return rowHeight }
        
        if node.isSeparator {
            // Separator rows have a smaller height.
            rowHeight = 8.0
        }
        return rowHeight
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        guard let node = TabBarViewController.node(from: item) else { return view }
        
        if node.isSeparator {
            // The row is a separator node, so make a custom view for it,.
            if let separator =
                outlineView.makeView(
                    withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Separator"), owner: self) as? NSBox {
                return separator
            }
        } else if self.outlineView(outlineView, isGroupItem: item) {
            // The row is a group node, so return NSTableCellView as a special group row.
            view = outlineView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GroupCell"), owner: self) as? NSTableCellView
            view?.textField?.stringValue = node.title.uppercased()
        } else {
            // The row is a regular outline node, so return NSTableCellView with an image and title.
            view = outlineView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MainCell"), owner: self) as? NSTableCellView
            
            view?.textField?.stringValue = node.title
            view?.imageView?.image = node.nodeIcon

            // Folder titles are editable only if they don't have a file URL,
            // You don't want users to rename file system-based nodes.
            view?.textField?.isEditable = node.canChange
        }

        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        NotificationCenter.default.post(
            name: Notification.Name(TabBarViewController.NotificationNames.selectionChanged),
            object: treeController)

        // Save the outline selection state for later when the app relaunches.
        self.invalidateRestorableState()
    }
}
