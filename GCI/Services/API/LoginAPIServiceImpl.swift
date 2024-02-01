//
//  LoginAPIServiceImpl.swift
//  Cerba
//
//  Created by Florian ALONSO on 4/28/17.
//  Copyright © 2017 Neopixl. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Reachability

class LoginAPIServiceImpl: BaseAPISerivceImpl, LoginAPIService {
    
    static let semaphoreRefreshToken = DispatchSemaphore(value: 1)
    
    override init() {
        super.init()
    }
    
    func authenticateUser(login: String, password: String, clientId: String, completionHandler: @escaping RequestJSONCallback) {
        let parameters: Alamofire.Parameters = [
            "username": login,
            "password": password,
            "grant_type": Constant.API.OAuth.grantTypePassword,
            "client_id": clientId,
            "scope": Constant.API.OAuth.oAuthClientScope
        ]
        
        if !NetworkReachabilityHelper.isReachable() {
            completionHandler(nil, .noInternet)
            return
        }
        
        alamoFireManager.request(Constant.API.EndPoint.login,
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    completionHandler(jsonObj, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    func logout(completionHandler: @escaping RequestStatusCallback) {
        // Not implemented on server
        completionHandler(.success)
    }
    
    func refreshUserToken(refreshToken: String, clientId: String, completionHandler: @escaping RequestJSONCallback) {
        
        var headers = defaultHeaders
        headers.remove(name: Constant.API.HeadersName.authorization)
        
        let parameters: Alamofire.Parameters = [
            "refresh_token": refreshToken,
            "grant_type": Constant.API.OAuth.grantTypeRefresh,
            "client_id": clientId,
            "scope": Constant.API.OAuth.oAuthClientScope
        ]
        
        alamoFireManager.request(Constant.API.EndPoint.refresh,
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let json = try? JSON(data: value){
                    
                    if requestStatus != .success {
                        print("Relogin failed should logout")
                        completionHandler(nil, requestStatus)
                    } else {
                        completionHandler(json, requestStatus)
                    }
                } else {
                    print("Relogin failed should logout")
                    completionHandler(nil, requestStatus)
                }
            }
    }
    
    /// Check the user token and launch a refresh request if needed
    ///
    /// - Parameter completionHandler: 
    func makeSecureCall(completionHandler: @escaping RequestJSONCallback) {
        LoginAPIServiceImpl.semaphoreRefreshToken.wait()
        
        if self.userIsAuth {
            completionHandler(nil, RequestStatus.success)
            LoginAPIServiceImpl.semaphoreRefreshToken.signal()
            return
        }

        if !NetworkReachabilityHelper.isReachable() {
            completionHandler(nil, RequestStatus.success)
            LoginAPIServiceImpl.semaphoreRefreshToken.signal()
            return
        }

        guard let user = User.currentUser(), let configuration = AppDynamicConfiguration.current(), let webRefreshToken = user.webRefreshToken else {
            completionHandler(nil, RequestStatus.shouldRelogin)
            LoginAPIServiceImpl.semaphoreRefreshToken.signal()
            return
        }
        
        self.refreshUserToken(refreshToken: webRefreshToken, clientId: configuration.ssoClientId) { (jsonOpt, requestStatus) in
            completionHandler(jsonOpt, requestStatus)
            LoginAPIServiceImpl.semaphoreRefreshToken.signal()
        }
    }
}
