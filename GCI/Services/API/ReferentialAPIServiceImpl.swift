//
//  ReferentialAPIServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ReferentialAPIServiceImpl: BaseAPISerivceImpl, ReferentialAPIService {
    
    func referention(withAlreadyKnowMaps idsMap: [Int], andwithAlreadyKnowZones idsZone: [Int], completion: @escaping RequestJSONCallback) {
        
        var headers = defaultHeaders
        
        let parameters: [String: Any] = [
            "knownMaps": idsMap,
            "knownZones": idsZone
        ]
        
        if let previousDate = UserDefaultManager.shared.lastReferentialRequestDate {
            headers[Constant.API.HeadersName.ifRange] = DateHelper.ifRangeDateFormater.string(from: previousDate)
        }
        
        alamoFireManager.request(Constant.API.EndPoint.referential,
                                 method: .put,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: headers)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                if response.response?.statusCode == 304 {
                    UserDefaultManager.shared.lastReferentialRequestDate = Date()
                    completion(nil, requestStatus)
                } else if response.response?.statusCode == 206 || response.response?.statusCode == 200 {
                    var jsonValue: JSON?
                    
                    if let value = response.data, let jsonObj = try? JSON(data: value) {
                        
                        //check lastModified header and compare to the lastReferentialRequestDate Date
                        if let lastModified = response.response?.allHeaderFields[Constant.API.HeadersName.lastModified] as? String {
                            let dateFormater = DateHelper.ifRangeDateFormater
                            if let dateAPI = dateFormater.date(from: lastModified) {
                                var shouldSaveJSON = true
                                
                                if let lastLaboratoriesRequestDate = UserDefaultManager.shared.lastReferentialRequestDate {
                                    if dateAPI <= lastLaboratoriesRequestDate {
                                        shouldSaveJSON = false
                                    }
                                    UserDefaultManager.shared.lastReferentialRequestDate = lastLaboratoriesRequestDate
                                } else {
                                    UserDefaultManager.shared.lastReferentialRequestDate = Date()
                                }
                                
                                if shouldSaveJSON {
                                    jsonValue = jsonObj
                                }
                            }
                            
                        } else {
                            jsonValue = jsonObj
                            UserDefaultManager.shared.lastReferentialRequestDate = Date()
                        }
                        
                    } else {
                        print("Error API : \(String(describing: response.error))")
                    }
                    
                    if let json = jsonValue {
                        completion(json, requestStatus)
                    } else {
                        completion(nil, requestStatus)
                    }
                    
                } else {
                    
                    completion(nil, requestStatus)
                }
        }
        
    }
}
