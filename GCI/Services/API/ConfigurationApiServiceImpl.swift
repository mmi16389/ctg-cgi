//
//  ConfigurationApiServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ConfigurationApiServiceImpl: BaseAPISerivceImpl, ConfigurationAPIService {
    
    func configuration(_ completionHandler: @escaping RequestJSONCallback) {
        alamoFireManager.request(Constant.API.EndPoint.configuration,
                                 method: .get,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: defaultHeaders)
        .validate(contentType: ["application/json"])
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
    
    func mapConfiguration(_ completionHandler: @escaping RequestJSONCallback) {
        alamoFireManager.request(Constant.API.EndPoint.configurationMap,
                                 method: .get,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: defaultHeaders)
        .validate(contentType: ["application/json"])
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
