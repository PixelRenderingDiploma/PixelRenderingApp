//
//  LoginViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-19.
//

import AppKit

class LoginViewController: PlatformViewController {
    @Service var authAdapter: MSAuthAdapter
    @Service var syncService: SyncService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sigIn(silently: true)
    }
    
    @IBAction func signInAction(_ sender: Any) {
        sigIn(silently: false)
    }
    
    private func sigIn(silently: Bool) {
        authAdapter.setupViewConnection(self)
        authAdapter.logIn(silently: true, type: .login) { [weak self] result in
            switch result {
            case .success(let auth):
                print(auth)
                self?.syncService.authorize(auth)
                self?.dismiss(nil)
            case .failure(let error):
                print(error)
            }
        }
    }
}
