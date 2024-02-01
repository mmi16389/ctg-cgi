//
//  UserAPIServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserAPIServiceImpl: BaseAPISerivceImpl, UserAPIService {
    
    func user(completionHandler: @escaping RequestJSONCallback) {
        alamoFireManager.request(Constant.API.EndPoint.user,
                                 method: .get,
                                 parameters: nil,
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
}
