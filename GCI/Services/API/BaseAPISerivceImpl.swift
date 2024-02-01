//
//  BaseAPISerivceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias RequestJSONCallback = (_ json: JSON?, _ requestStatus: RequestStatus) -> Void
typealias RequestStatusCallback = (_ requestStatus: RequestStatus) -> Void

class BaseAPISerivceImpl: NSObject {
    
    let alamoFireManager: Session
    lazy var correlationId: String = {
        return UUID().uuidString
    }()
    
    var userIsAuth: Bool {
        return User.currentUser()?.tokenIsValid ?? false
    }
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constant.API.Durations.timoutMs / 1000
        configuration.timeoutIntervalForResource = Constant.API.Durations.timoutMs / 1000
        alamoFireManager = Alamofire.Session(configuration: configuration)
        
        super.init()
        
    }
    
    var defaultHeaders: Alamofire.HTTPHeaders {
        var headers: Alamofire.HTTPHeaders = [
            Constant.API.HeadersName.correlationId: correlationId
            ]
        
        if let key = KeychainManager.shared.licenceKey {
            headers[Constant.API.HeadersName.apiKey] = key
        }
        
        // Map projection
        if let user = User.currentUser(), let token = user.webToken, user.tokenIsValid {
            let authType: String
            if Constant.API.useBasicAuth {
                authType = "Basic"
            } else {
                authType = "Bearer"
            }
            headers[Constant.API.HeadersName.authorization] = "\(authType) \(token)"
        }
        
        return headers
    }
    
    func ifRangeHeader(date: Date) -> Alamofire.HTTPHeaders {
        
        let dateString = DateHelper.ifRangeDateFormater.string(from: date)
        
        let header: HTTPHeaders = [Constant.API.HeadersName.ifRange: dateString]
        
        return header
    }
    
}
