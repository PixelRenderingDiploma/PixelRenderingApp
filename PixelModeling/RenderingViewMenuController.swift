//
//  RenderingViewMenuController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-23.
//

import AppKit

protocol RenderingViewMenuControllerDelegate: AnyObject {
    func didAddShape(_ shape: BasicShape)
    func didRemoveShape()
}

class RenderingViewMenuController {
    weak var delegate: RenderingViewMenuControllerDelegate?
    
    lazy var menu: NSMenu = {
        let menu = NSMenu(title: "Rendering view options menu")
        
        let menuItem1 = NSMenuItem(title: "Add", action: nil, keyEquivalent: "A")
        menuItem1.target = self
        menu.addItem(menuItem1)
        
        let addSubmenu = NSMenu(title: "Add")
        menuItem1.submenu = addSubmenu
        
        BasicShape.allCases.forEach {
            let menuItem = NSMenuItem(title: $0.title.capitalized, action: #selector(didAddShape), keyEquivalent: "")
            menuItem.target = self
            menuItem.tag = $0.rawValue
            addSubmenu.addItem(menuItem)
        }
        
        let menuItem2 = NSMenuItem(title: "Delete", action: #selector(didRemoveShape), keyEquivalent: "")
        menuItem2.target = self
        menu.addItem(menuItem2)
        
        return menu
    }()
    
    func validate() {
        // TODO: validate click position
    }
    
    @objc
    private func didAddShape(sender: Any?) {
        guard let item = sender as? NSMenuItem,
              let shape = BasicShape(rawValue: item.tag) else {
            return
        }
        
        delegate?.didAddShape(shape)
    }
    
    @objc
    private func didRemoveShape(sender: Any?) {
        delegate?.didRemoveShape()
    }
}
