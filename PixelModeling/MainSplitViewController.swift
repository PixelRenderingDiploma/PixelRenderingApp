//
//  MainSplitViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-31.
//

import AppKit

class MainSplitViewController: NSSplitViewController {
    @Service var authAdapter: MSAuthAdapter
    
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectionChange(_:)),
            name: Notification.Name(TabBarViewController.NotificationNames.selectionChanged),
            object: nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if authAdapter.authState.idToken == nil,
           let viewController = self.storyboard?.instantiateController(withIdentifier: "LoginViewController") as? LoginViewController {
            self.presentAsSheet(viewController)
        }
    }
    
    private var detailViewController: DetailedViewController {
        splitViewItems[1].viewController as! DetailedViewController
    }
    
    private var hasChildViewController: Bool {
        return !detailViewController.children.isEmpty
    }
    
    private func embedChildViewController(_ childViewController: NSViewController) {
        // This embeds a new child view controller.
        let currentDetailVC = detailViewController
        currentDetailVC.addChild(childViewController)
        currentDetailVC.containerView?.addSubview(childViewController.view)
        
        // Build the horizontal, vertical constraints so that an added child view controller matches the width and height of its parent.
        let views = ["targetView": childViewController.view]
        horizontalConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[targetView]|",
                                           options: [],
                                           metrics: nil,
                                           views: views)
        NSLayoutConstraint.activate(horizontalConstraints)
        
        verticalConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[targetView]|",
                                           options: [],
                                           metrics: nil,
                                           views: views)
        NSLayoutConstraint.activate(verticalConstraints)
    }
    
    // MARK: Notifications
    
    // Listens for selection changes to the NSTreeController.
    @objc
    private func handleSelectionChange(_ notification: Notification) {
        // Examine the current selection and adjust the UI.
        
        // Make sure the notification's object is a tree controller.
        guard let treeController = notification.object as? NSTreeController else { return }
        
        let leftSplitViewItem = splitViewItems[0]
        if let tabBarViewControllerToObserve = leftSplitViewItem.viewController as? TabBarViewController {
            let currentDetailVC = detailViewController
            
            // Let the outline view controller handle the selection (helps you decide which detail view to use).
            if let vcForDetail = tabBarViewControllerToObserve.viewControllerForSelection(treeController.selectedNodes) {
                if hasChildViewController && currentDetailVC.children[0] != vcForDetail {
                    /** The incoming child view controller is different from the one you currently have,
                        so remove the old one and add the new one.
                    */
                    currentDetailVC.removeChild(at: 0)
                    // Remove the old child detail view.
                    detailViewController.containerView?.subviews[0].removeFromSuperview()
                    // Add the new child detail view.
                    embedChildViewController(vcForDetail)
                } else {
                    if !hasChildViewController {
                        // You don't have a child view controller, so embed the new one.
                        embedChildViewController(vcForDetail)
                    }
                }
            } else {
                // No selection. You don't have a child view controller to embed, so remove the current child view controller.
                if hasChildViewController {
                    currentDetailVC.removeChild(at: 0)
                    detailViewController.containerView?.subviews[0].removeFromSuperview()
                }
            }
        }
    }
}
