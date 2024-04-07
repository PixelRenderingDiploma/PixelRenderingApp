//
//  TabBarViewController+DragDrop.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-31.
//

import Cocoa

extension TabBarViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pasteboard = NSPasteboardItem(pasteboardPropertyList: [], ofType: .fileURL)
        
        return pasteboard
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        var dragOperation: NSDragOperation = []
        
        if let draggingSource = info.draggingSource as? NSOutlineView {
//            dragOperation.insert(.move)
        } else {
            if let treeNode = item as? NSTreeNode,
               let node = treeNode.representedObject as? Node,
               node.identifier == Node.projectsID,
               index == -1 /* accept drop on node itself */ {
                dragOperation.insert(.copy)
            } else if item == nil {
                dragOperation.insert(.copy)
            }
        }
        
        return dragOperation
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        info.enumerateDraggingItems(
            options: .concurrent,
            for: outlineView,
            classes: [NSPasteboardItem.self],
            searchOptions: [:]) { [weak self] draggingItem, idx, stop in
                guard let pasteboardItem = draggingItem.item as? NSPasteboardItem,
                      let itemType = pasteboardItem.availableType(from: [.fileURL]),
                      let filePath = pasteboardItem.string(forType: itemType),
                      let url = URL(string: filePath) else {
                    return
                }
                
                self?.importModel(url: url)
            }
        
        return true
    }
}
