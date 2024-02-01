//
//  NotificationAPIServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NotificationAPIServiceImpl: BaseAPISerivceImpl, NotificationAPIService {
    
    func register(token: String, completionHandler:  @escaping RequestStatusCallback) {
        alamoFireManager.request(Constant.API.EndPoint.notification(withToken: token),
                                 method: .post,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                completionHandler(requestStatus)
        }
    }
    
    func unregister(token: String, completionHandler: @escaping RequestStatusCallback) {
        alamoFireManager.request(Constant.API.EndPoint.notification(withToken: token),
                                 method: .delete,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                completionHandler(requestStatus)
        }
    }
    
    func getSubscription(completionHandler:  @escaping NotificationAPIService.SubscriptionCallback) {
        alamoFireManager.request(Constant.API.EndPoint.notification,
                                 method: .get,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    let values = jsonObj["subscription"].arrayValue
                        .compactMap {
                            $0.int
                    }
                    completionHandler(values, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler([], requestStatus)
                }
        }
    }
    
    func updateSubscription(subscriptionList: [Int], completionHandler:  @escaping  NotificationAPIService.SubscriptionCallback) {
        
        var parameters = [String: Any]()
        parameters["subscription"] = subscriptionList
        
        alamoFireManager.request(Constant.API.EndPoint.notification,
                                 method: .put,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success {
                    completionHandler(subscriptionList, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler([], requestStatus)
                }
        }
    }
    
}
