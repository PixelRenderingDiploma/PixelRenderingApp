//
//  MSAuthAdapter.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-19.
//

import os
import Combine
import MSAL

class MSAuthState: ObservableObject {
    @Published var account: Account?
    var idToken: String?
    var idUser: String?
}

struct Account {
    static let undefinedValue = "[Undefined]"
    
    let name: String
    let email: String
}

class MSAuthAdapter {
    static let logger = Logger(subsystem: AppDelegate.subsystem,
                               category: "MSAuth")
    
    let authState = MSAuthState()
    private let authProxy = MSAuthProxy()
    
    private let tenantName = "hlebushek.onmicrosoft.com"
    private let authorityHostName = "hlebushek.b2clogin.com"
    private let clientId = "fdfc1e35-a8cc-426f-b28f-477a4d1f25de"
    private let signupOrSigninPolicy = "B2C_1_susi"
    private let resetPasswordPolicy = "B2C_1_reset"
    private let redirectUri = "msauth.hlebushek.PixelModeling://auth"
    private let graphURI = "https://graph.microsoft.com/"
    private let scopes: [String] = []
    private let endpoint = "https://%@/tfp/%@/%@"
    
    init() {
        setupApplication()
    }
    
    func setupViewConnection(_ viewController: PlatformViewController) {
        authProxy.connectWith(viewController: viewController)
    }
    
    func logIn(silently: Bool, type: MSALPromptType, completion: ((Result<MSAuthState, Error>) -> Void)? = nil) {
        loadAccount { account in
            if account != nil {
                self.acquireTokenSilently(completion: completion)
            } else if !silently {
                self.acquireTokenInteractively(type: type, completion: completion)
            } else {
                completion?(.failure(MSAuthProxy.Error.interactiveLoginRequired))
            }
        }
    }

    func logOut(completion: (() -> Void)? = nil) {
        authProxy.logout { error in
            if let error = error {
                MSAuthAdapter.logger.error("Couldn't sign out account with error: \(String(describing: error))")
                self.resetState()
                completion?()
                return
            }

            MSAuthAdapter.logger.debug("Sign out completed successfully")
            self.resetState()
            completion?()
        }
    }
    
    private func setupApplication() {
        guard let authorityUrl = URL(string: String(format: self.endpoint, self.authorityHostName, self.tenantName, self.signupOrSigninPolicy)) else {
            MSAuthAdapter.logger.error("Unable to create authority URL")
            return
        }
        
        do {
            try authProxy.setupApplication(clientId: clientId, redirectUri: redirectUri, authorityUrl: authorityUrl)
        } catch {
            MSAuthAdapter.logger.error("Unable to create Application Context: \(String(describing: error))")
        }
    }
    
    private func setupResetPassword() {
        guard let authorityUrl = URL(string: String(format: self.endpoint, self.authorityHostName, self.tenantName, self.resetPasswordPolicy)) else {
            MSAuthAdapter.logger.error("Unable to create authority URL")
            return
        }
        
        do {
            try authProxy.setupApplication(clientId: clientId, redirectUri: redirectUri, authorityUrl: authorityUrl)
        } catch {
            MSAuthAdapter.logger.error("Unable to create Reset Password Application Context: \(String(describing: error))")
        }
    }
    
    private func loadAccount(_ completion: @escaping (Account?) -> Void) {
        authProxy.loadAccount { account, error in
            if let error {
                MSAuthAdapter.logger.error("Couldn't query current account with error: \(String(describing: error))")
                
                if let nsError = (error as NSError?),
                   nsError.userInfo[MSALInternalErrorCodeKey] as? Int == MSALInternalError.internalErrorAmbiguousAccount.rawValue {
                    self.authProxy.clearAccountCache()
                }
                
                completion(nil)
                return
            }

            if let account {
                MSAuthAdapter.logger.error("Found a signed in account \(account.email). Updating data for that account...")
                completion(account)
                return
            }

            MSAuthAdapter.logger.debug("Account signed out.")
            self.resetState()
            completion(nil)
        }
    }
    
    private func acquireTokenInteractively(type: MSALPromptType, completion: ((Result<MSAuthState, Error>) -> Void)? = nil) {
        authProxy.acquireTokenInteractively(type: type, scopes: scopes) { account, idToken, idUser, error in
            guard let account else {
                MSAuthAdapter.logger.error("Could not acquire token: No account returned")
                
                if let error, (error as NSError).code == -50005 {
                    self.setupResetPassword()
                    DispatchQueue.main.async {
                        self.acquireTokenInteractively(type: .login, completion: completion)
                    }
                } else {
                    completion?(.failure(error ?? MSAuthProxy.Error.couldNotAcquireToken))
                }
                
                return
            }

            MSAuthAdapter.logger.debug("Acquired access token interactively")
            
            DispatchQueue.main.async {
                self.setAccount(account)
                self.setIdToken(idToken)
                self.setUserId(idUser)
                completion?(.success(self.authState))
            }
        }
    }
    
    private func acquireTokenSilently(completion: ((Result<MSAuthState, Error>) -> Void)? = nil) {
        authProxy.acquireTokenSilently(msScopes: scopes) { account, idToken, idUser, error in
            guard let account else {
                MSAuthAdapter.logger.error("Could not acquire token: No account returned")
                if let error {
                    if (error as? MSAuthProxy.Error) == .interactiveLoginRequired {
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively(type: .login, completion: completion)
                        }
                    } else if (error as NSError).code == -50005 {
                        self.setupResetPassword()
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively(type: .login, completion: completion)
                        }
                    } else {
                        completion?(.failure(error))
                    }
                } else {
                    completion?(.failure(MSAuthProxy.Error.couldNotAcquireToken))
                }
                
                return
            }

            MSAuthAdapter.logger.debug("Refreshed Access token")
            
            DispatchQueue.main.async {
                self.setAccount(account)
                self.setIdToken(idToken)
                self.setUserId(idUser)
                completion?(.success(self.authState))
            }
        }
    }
    
    func openUrl(url: URL) {
        authProxy.openUrl(url: url)
    }
    
    func loadDeviceMode() {
        authProxy.deviceMode { deviceMode, error in
            if let deviceMode = deviceMode {
                MSAuthAdapter.logger.log("Received device info. Device is in the \(deviceMode) mode.")
            } else {
                MSAuthAdapter.logger.error("Device info not returned. Error: \(String(describing: error))")
            }
        }
    }
    
    private func resetState() {
        DispatchQueue.main.async {
            self.setAccount(nil)
            self.setIdToken(nil)
            self.setUserId(nil)
        }
    }
    
    private func setAccount(_ account: Account?) {
        self.authState.account = account
    }
    
    private func setIdToken(_ idToken: String?) {
        self.authState.idToken = idToken
    }
    
    private func setUserId(_ id: String?) {
        self.authState.idUser = id
    }
}
