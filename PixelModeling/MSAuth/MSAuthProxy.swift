//
//  MSAuthProxy.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-19.
//

import MSAL

extension MSALAccount {
    var mappedAccount: Account {
        Account(
            name: accountClaims?["name"] as? String ?? accountClaims?["given_name"] as? String ?? Account.undefinedValue,
            email: (accountClaims?["emails"] as? [String])?.first ?? Account.undefinedValue
        )
    }
}

class MSAuthProxy {
    enum Error: Swift.Error {
        case couldNotAcquireToken
        case interactiveLoginRequired
        case multiplyAccountFound
    }
    
    private var application: MSALPublicClientApplication?
    private var webViewParameters: MSALWebviewParameters?
    private var account: MSALAccount?
    
    func setupApplication(clientId: String, redirectUri: String, authorityUrl: URL) throws {
        let authority = try MSALB2CAuthority(url: authorityUrl)
        let configuration = MSALPublicClientApplicationConfig(
            clientId: clientId,
            redirectUri: redirectUri,
            authority: authority
        )
        configuration.knownAuthorities = [authority]
        
        application = try MSALPublicClientApplication(configuration: configuration)
    }
    
    func connectWith(viewController: PlatformViewController) {
        webViewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
#if os(iOS)
        webViewParameters?.webviewType = .safariViewController
#elseif os(macOS)
        webViewParameters?.webviewType = .authenticationSession
#endif
    }
    
    func loadAccount(completion: @escaping (Account?, Swift.Error?) -> Void) {
        guard let application else { return }

        let parameters = MSALParameters()
        parameters.completionBlockQueue = DispatchQueue.main

        application.getCurrentAccount(with: parameters) { account, _, error in
            self.account = account
            completion(account?.mappedAccount, error)
        }
    }
    
    func clearAccountCache() {
        guard let application else {
            return
        }
        
        let allAccounts = try? application.allAccounts()
        
        if let accounts = allAccounts {
            for account in accounts {
                try? application.remove(account)
            }
        }
    }
    
    func logout(completion: @escaping (Swift.Error?) -> Void) {
        guard let application, let account else {
            completion(nil)
            return
        }

        self.account = nil
        
        let signoutParameters = MSALSignoutParameters(webviewParameters: webViewParameters!)
        signoutParameters.signoutFromBrowser = false
        
        application.signout(with: account, signoutParameters: signoutParameters) { _, error in
            completion(error)
        }
    }
    
    func acquireTokenInteractively(type: MSALPromptType, scopes: [String], completion: @escaping (Account?, String?, String?, Swift.Error?) -> Void) {
        guard let application, let webViewParameters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webViewParameters)
        parameters.promptType = type

        application.acquireToken(with: parameters) { result, error in
            self.account = result?.account
            completion(self.account?.mappedAccount, result?.idToken, result?.tenantProfile.identifier, error)
        }
    }
    
    func acquireTokenSilently(msScopes: [String], completion: @escaping (Account?, String?, String?, Swift.Error?) -> Void) {
        guard let application, let account else {
            completion(nil, nil, nil, Error.interactiveLoginRequired)
            return
        }

        let parameters = MSALSilentTokenParameters(scopes: msScopes, account: account)

        application.acquireTokenSilent(with: parameters) { result, error in
            self.account = result?.account
            var newError: Swift.Error? = error
            
            if let nsError = error as NSError?,
               nsError.domain == MSALErrorDomain,
               nsError.code == MSALError.interactionRequired.rawValue {
                newError = Error.interactiveLoginRequired
            }
            
            completion(result?.account.mappedAccount, result?.idToken, result?.tenantProfile.identifier, newError)
        }
    }
    
    func openUrl(url: URL) {
#if os(iOS)
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
#endif  
    }
    
    func deviceMode(completion: @escaping (String?, Swift.Error?) -> Void) {
        application?.getDeviceInformation(with: nil) { deviceInformation, error in
            guard let deviceInfo = deviceInformation else {
                completion(nil, error)
                return
            }
            
            let deviceMode = deviceInfo.deviceMode == .shared ? "shared" : "private"
            completion(deviceMode, error)
        }
    }
}
