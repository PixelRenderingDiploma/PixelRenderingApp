//
//  ProcessingButton.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-03-31.
//

import Cocoa

class ProcessingButton: NSButton {
    var asyncAction: ( (_ sender: Any) async -> Void )?

    private let spinner: NSProgressIndicator = {
        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.isDisplayedWhenStopped = false
        spinner.controlSize = .small
        return spinner
    }()
    
    private var initialTitle: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(spinner)
        spinner.frame = CGRect(x: (bounds.width - 16) / 2, y: (bounds.height - 16) / 2, width: 16, height: 16)
        spinner.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let action = asyncAction else { return }

        isEnabled = false
        
        initialTitle = title
        title = ""
        
        spinner.startAnimation(nil)

        Task {
            await action(self)

            DispatchQueue.main.async { [weak self] in
                self?.isEnabled = true
                self?.title = self?.initialTitle ?? ""
                self?.spinner.stopAnimation(nil)
            }
        }
    }
    
    func setLoading(_ sender: Any, loading: Bool) {
        if loading {
            spinner.isHidden = false
            spinner.startAnimation(sender)
            isEnabled = false
        } else {
            spinner.isHidden = true
            spinner.stopAnimation(sender)
            isEnabled = true
        }
    }
}
