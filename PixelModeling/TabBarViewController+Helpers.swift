//
//  TabBarViewController+Helpers.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-31.
//

import Cocoa
import UniformTypeIdentifiers

extension TabBarViewController {
    // Returns a generic node (folder or leaf) from a specified URL.
    class func fileSystemNode(from url: URL) -> Node {
        let node = Node()
        node.url = url
        
        if url.isFolder {
            node.type = .container
        } else {
            node.type = .document
        }
        // Figure out the node's name from the URL.
        node.title = url.localizedName
        
        return node
    }
    
    // Return a Node class from the specified outline view item through its representedObject.
    class func node(from item: Any) -> Node? {
        if let treeNode = item as? NSTreeNode, let node = treeNode.representedObject as? Node {
            return node
        } else {
            return nil
        }
    }
}

extension URL {
    // Returns true if this URL is a file system container (packages aren't containers).
    var isFolder: Bool {
        var isFolder = false
        if let resources = try? resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]) {
            let isURLDirectory = resources.isDirectory ?? false
            let isPackage = resources.isPackage ?? false
            isFolder = isURLDirectory && !isPackage
        }
        return isFolder
    }
    
    var icon: NSImage {
        var icon: NSImage!
        if let iconValues = try? resourceValues(forKeys: [.customIconKey, .effectiveIconKey]) {
            if let customIcon = iconValues.customIcon {
                icon = customIcon
            } else if let effectiveIcon = iconValues.effectiveIcon as? NSImage {
                icon = effectiveIcon
            }
        } else {
            icon = NSWorkspace.shared.icon(forFile: self.path())
        }
        return icon
    }
    
    // Returns the human-visible localized name.
    var localizedName: String {
        var localizedName = ""
        if let fileNameResource = try? resourceValues(forKeys: [.localizedNameKey]) {
            localizedName = fileNameResource.localizedName!
        } else {
            // Failed to get the localized name, so use it's last path component as the name.
            localizedName = lastPathComponent
        }
        return localizedName
    }
}
