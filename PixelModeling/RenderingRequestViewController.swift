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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControls()
    }
    
    private func setupControls() {
        RenderingType.allCases.forEach {
            renderingTypePopupButton.addItem(withTitle: $0.title)
            renderingTypePopupButton.lastItem?.tag = $0.rawValue
        }
    }
    
    @IBAction func typeDidChange(_ sender: NSPopUpButton) {
        if sender == renderingTypePopupButton {
            print(sender.selectedTag())
        }
    }
    
    
    @IBAction func submitButtonAction(_ sender: Any) {
        guard let id,
              let type = RenderingType(rawValue: renderingTypePopupButton.selectedTag()) else {
            return
        }
        
        let delegate = (NSApplication.shared.delegate as? AppDelegate)
        Task {
            try await delegate?.webApi.submitRendering(id: id, renderingType: type)
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(self)
    }
}
