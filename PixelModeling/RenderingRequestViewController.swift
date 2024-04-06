//
//  RenderingRequestViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-04.
//

import Cocoa

class RenderingRequestViewController: NSViewController {
    var id: UUID?

    @IBOutlet weak var renderingTypePopupButton: NSPopUpButton!
    @IBOutlet weak var frameField: NSTextField!
    
    @IBOutlet weak var sceneEffectPopupButton: NSPopUpButton!
    @IBOutlet weak var postEffectPopupButton: NSPopUpButton!
    
    @IBOutlet weak var submitButton: ProcessingButton?
    
    private let infoPopover = {
        let popover = NSPopover()
        popover.contentViewController = RenderingSettingsInfoPopoverViewController()
        popover.behavior = .semitransient
        return popover
    }()
    
    @Service var authAdapter: MSAuthAdapter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControls()
    }
    
    private func setupControls() {
        frameField.formatter = NumberFormatter()
        
        RenderingType.allCases.forEach {
            renderingTypePopupButton.addItem(withTitle: $0.title)
            renderingTypePopupButton.lastItem?.tag = $0.rawValue
        }
        
        SceneEffect.allCases.forEach {
            sceneEffectPopupButton.addItem(withTitle: $0.title)
            sceneEffectPopupButton.lastItem?.tag = $0.rawValue
        }
        
        PostEffect.allCases.forEach {
            postEffectPopupButton.addItem(withTitle: $0.title)
            postEffectPopupButton.lastItem?.tag = $0.rawValue
        }
        
        submitButton?.asyncAction = submitButtonAction
    }
    
    @IBAction func typeDidChange(_ sender: NSPopUpButton) {
        if sender == renderingTypePopupButton {
            switch sender.selectedTag() {
            case 0:
                frameField.isEnabled = true
            default:
                frameField.isEnabled = false
            }
        }
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {
        guard !infoPopover.isShown,
              let view = sender as? NSView else {
            return
        }
        
        infoPopover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxY)
    }
    
    func submitButtonAction(_ sender: Any) async {
        guard let id_model = id,
              let type = RenderingType(rawValue: renderingTypePopupButton.selectedTag()),
              let sceneEffect = SceneEffect(rawValue: sceneEffectPopupButton.selectedTag()),
              let postEffect = PostEffect(rawValue: postEffectPopupButton.selectedTag()),
              let startFrame = Int(frameField.stringValue) else {
            return
        }
        
        let settings = RenderingSettings(type: type, flyby: .circleHorizontal, scene_effect: sceneEffect, post_effect: postEffect, duration: 0, start_frame: startFrame)
        
        let id = UUID()
        
        try? await WebApi(authAdapter.authState).submitRendering(id: id, id_model: id_model, settings: settings)
        
        self.cancelButtonAction(sender)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(self)
    }
}
