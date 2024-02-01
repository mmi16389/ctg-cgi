//
//  MapAPIServiceImpl.swift
//  GCI
//
//  Created by Anthony Chollet on 07/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MapAPIServiceImpl: BaseAPISerivceImpl, MapAPIService {
    func getAddress(fromX x: Double, andY y: Double, completionHandler: @escaping RequestJSONCallback) {
        
        if !NetworkReachabilityHelper.isReachable() {
            completionHandler(nil, .noInternet)
            return
        }
        
        var baseGeocodeUrl = Constant.Map.mapGeocoderUrl
        if let config = AppDynamicConfiguration.current(), let configUrl = config.geocodingServiceUrl {
            baseGeocodeUrl = configUrl
        }
        let geocodeUrl = baseGeocodeUrl + Constant.Map.mapReverseGeocoderUrl
        
        let urlString = geocodeUrl.replacingOccurrences(of: "{PointX}", with: "\(x)").replacingOccurrences(of: "{PointY}", with: "\(y)")
        
        alamoFireManager.request(urlString,
                                 method: .post,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: [:])
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
