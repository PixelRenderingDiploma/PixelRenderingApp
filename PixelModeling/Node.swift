//
//  Node.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-31.
//

import Cocoa
import UniformTypeIdentifiers

enum NodeType: Int, Codable {
    case container
    case project
    case projectParagraph
    case document
    case separator
    case unknown
}

class Node: NSObject, Codable {
    var type: NodeType = .unknown
    var title: String = ""
    var identifier: String = ""
    var url: URL?
    @objc dynamic var children = [Node]()
}

extension Node {
    struct NameConstants {
        // The default name for added folders and leafs.
        static let untitled = NSLocalizedString("untitled string", comment: "")
        // The projects group title.
        static let projects = NSLocalizedString("projects string", comment: "")
        // The other group title.
        static let other = NSLocalizedString("other string", comment: "")
    }
    
    static let projectsID = "1000"
    static let otherID = "1001"
    
    /** The tree controller calls this to determine if this node is a leaf node,
     use it to determine if the node needs a disclosure triangle.
     */
    @objc dynamic var isLeaf: Bool {
        return type == .document || type == .separator
    }
    
    var isURLNode: Bool {
        return url != nil
    }
    
    var isSpecialGroup: Bool {
        // A group node is a special node that represents either Pictures or Places as grouped sections.
        return (!isURLNode &&
            (title == Node.NameConstants.projects || title == Node.NameConstants.other))
    }
    
    var isRemote: Bool {
        url?.isPlaceholder ?? false
    }
    
    override class func description() -> String {
        return "Node"
    }
    
    var nodeIcon: NSImage {
        var icon = NSImage()
        if let nodeURL = url {
            if isRemote,
               let cloudIcon = NSImage(systemSymbolName: "cloud", accessibilityDescription: nil) {
                icon = cloudIcon
            } else {
                // If the node has a URL, use it to obtain its icon.
                icon = nodeURL.icon
            }
        } else {
            // There's no URL for this node, so determine its icon generically.
            let type = isDirectory ? UTType.folder : UTType.image
            icon = NSWorkspace.shared.icon(for: type)
        }
        return icon
    }
    
    var canChange: Bool {
        // You can only change (rename or add to) non-URL based directory nodes.
        return isDirectory && url == nil
    }
    
    var canAddTo: Bool {
        return isDirectory && canChange
    }
    
    var isSeparator: Bool {
        return type == .separator
    }
    
    var isDirectory: Bool {
        return type == .container || type == .project || type == .projectParagraph
    }
}
