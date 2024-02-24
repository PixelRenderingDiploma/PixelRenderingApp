//
//  AppDelegate.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-09.
//

import Cocoa
import UniformTypeIdentifiers

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    static let subsystem: String = Bundle.main.bundleIdentifier ?? "hlebushek.PixelModeling-iOS"
    
    let webApi = WebApi()
    
    override init() {
        super.init()
        setupDependencyContainer()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func setupDependencyContainer() {
        ServiceContainer.register(type: MSAuthAdapter.self, MSAuthAdapter())
        ServiceContainer.register(type: StorageManagerProtocol.self, StorageManagerMacOS())
    }
}

