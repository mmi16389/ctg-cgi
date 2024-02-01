//
//  LoginAPIServiceImpl+Basic.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Reachability

class LoginAPIServiceBasicImpl: LoginAPIServiceImpl {
    
    override func authenticateUser(login: String, password: String, clientId: String, completionHandler: @escaping RequestJSONCallback) {
        let parameters: Alamofire.Parameters = [
            "Login": login,
            "Password": password
        ]
        
        if !NetworkReachabilityHelper.isReachable() {
            completionHandler(nil, .noInternet)
            return
        }
        
        alamoFireManager.request(Constant.API.EndPoint.login,
                                 method: .post,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
        .validate(contentType: ["application/json"])
        .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
            if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    
                    var dict = [String: Any]()
                    dict["access_token"] = jsonObj["authToken"].string
                    dict["expires_in"] = Int.max
                    dict["token_type"] = ""
                    dict["refresh_token"] = "Basic"
                    completionHandler(JSON(dict), requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    override func refreshUserToken(refreshToken: String, clientId: String, completionHandler: @escaping RequestJSONCallback) {
        guard let user = User.currentUser() else {
            completionHandler(nil, .error)
            return
        }
        var dict = [String: Any]()
        dict["access_token"] = user.webToken
        dict["expires_in"] = Int.max
        dict["token_type"] = ""
        dict["refresh_token"] = "Basic"
        
        completionHandler(JSON(dict), .success)
    }
}
