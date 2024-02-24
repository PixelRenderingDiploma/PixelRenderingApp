//
//  PlatformViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-03.
//

import Foundation

class DetailedViewController: PlatformViewController {
    /** You embed a child view controller into the detail view controller each time a different outline view item becomes selected.
        For the split view controller to consistently remain in the responder chain, the detail view controller's view property needs to
        accept first responder status. This is especially important for the consistent validation of the Show/Hide Sidebar
        menu item in the View menu.
    */
    override var acceptsFirstResponder: Bool { return true }
}
