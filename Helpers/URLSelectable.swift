//
//  URLSelectable.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-19.
//

import AppKit

protocol URLSelectable {
    func urlForSelection() -> URL?
}

class NotificationCollectionView: NSCollectionView {
    var selectionObservation: NSKeyValueObservation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionObservation = observe(\.selectionIndexPaths, options: [.new, .old]) { [weak self] (collectionView, change) in
            if change.newValue != change.oldValue {
                NotificationCenter.default.post(name: .collectionViewSelectionDidChange, object: self)
            }
        }
    }
}

class SubSelectionCollectionView: NotificationCollectionView {
    typealias ViewItem = NSCollectionViewItem & SubSelectionCollectionViewItem
    var subselectionIndexPaths: Set<IndexPath> = [] {
        didSet {
            NotificationCenter.default.post(
                name: .collectionViewSelectionDidChange,
                object: self)
        }
    }
    
    func validateSelection(for indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        return Set(indexPaths.compactMap { indexPath in
            guard let item = item(at: indexPath) as? ViewItem,
                  let lastEvent = NSApp.currentEvent else {
                return indexPath
            }
            
            let localPoint = item.view.convert(lastEvent.locationInWindow, from: nil)
            
            if let subitemIndex = item.subitemIndex(at: localPoint) {
                item.select()
                subselectionIndexPaths = [IndexPath(item: subitemIndex, section: indexPath.item)]
                return nil
            }
            
            return indexPath
        })
    }
}

protocol SubSelectionCollectionViewItem {
    func subitemIndex(at point: NSPoint) -> Int?
    func object(for selection: Int) -> Any?
    func select()
}

extension Notification.Name {
     static let collectionViewSelectionDidChange = Notification.Name("collectionViewSelectionDidChange")
}
