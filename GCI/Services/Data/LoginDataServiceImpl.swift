//
//  LoginDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class LoginDataServiceImpl: NSObject, LoginDataService {
    
    var internalApiService: LoginAPIService?
    
    override init() {
        super.init()
    }
    
    func apiService() -> LoginAPIService {
        if internalApiService == nil {
            if Constant.API.useBasicAuth {
                self.internalApiService = LoginAPIServiceBasicImpl()
            } else {
                self.internalApiService = LoginAPIServiceImpl()
            }
        }
        return internalApiService!
    }
    
    func authenticateUser(login: String, password: String, completionHandler: @escaping LoginDataService.AuthenticateCallback) {
        guard let configuration = AppDynamicConfiguration.current() else {
            completionHandler(.failed(.error))
            return
        }
        
        apiService().authenticateUser(login: login, password: password, clientId: configuration.ssoClientId) { (jsonOpt, requestStatus) in
            
            // Network error handling
            print("Request status : \(requestStatus)")
            
            if requestStatus != .success && requestStatus != .badRequest {
                completionHandler(.failed(ViewModelError.from(networkRequest: requestStatus)))
                return
            } else if requestStatus == .badRequest {
                completionHandler(.failed(.notRightUsername))
                return
            }
            
            DispatchQueue.global().async {
                guard let json = jsonOpt,
                    let accessToken = json["access_token"].string,
                    let expireIn = json["expires_in"].int,
                    let refreshToken = json["refresh_token"].string else {
                        completionHandler(.failed(.error))
                        return
                }
                
                let user = User.login(id: "GUEST", webToken: accessToken, webRefreshToken: refreshToken, webRefreshExpireInSeconds: expireIn)
                user.save()
                
                DispatchQueue.main.async {
                    completionHandler(.value(user))
                }
            }
        }
    }
    
    /// Ensure that the api call in the completion handler will be with a valide user token
    ///
    /// - Parameter completionHandler: secured completion handler for the API calls
    func makeSecureAPICall(completionHandler: @escaping LoginDataService.VoidCallback) {
        apiService().makeSecureCall { (jsonOpt, requestStatus) in
            DispatchQueue.global().async {
                guard let json = jsonOpt,
                    let accessToken = json["access_token"].string,
                    let expireIn = json["expires_in"].int else {
                        
                        if requestStatus == .success {
                            // No JSON found
                            // This case no JSON required because token still valid
                            completionHandler()
                        } else {
                            // A relogin has been tried and an error occured
                            NotificationCenter.default.post(name: Notification.Name.applicationShouldLogout, object: nil)
                        }
                        return
                }
                
                guard let user = User.currentUser() else {
                    // If no request has been launch the user should exit, fall back to logout
                    NotificationCenter.default.post(name: Notification.Name.applicationShouldLogout, object: nil)
                    return
                }
                let newRefreshToken: String
                if let refresh = json["refresh_token"].string {
                    newRefreshToken = refresh
                } else {
                    newRefreshToken = user.webRefreshToken ?? ""
                }
                
                user.refreshToken(webToken: accessToken, webRefreshToken: newRefreshToken, webRefreshExpireInSeconds: expireIn)
                user.save()
                
                // Token correctly refreshed
                completionHandler()
            }
        }
    }
    
}
