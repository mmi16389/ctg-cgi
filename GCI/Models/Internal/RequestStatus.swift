//
//  RequestStatus.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

enum RequestStatus {
    case success
    case error
    case noInternet
    case shouldRelogin
    case tokenError
    case notFound
    case badRequest
    case deniedForEver
    case notRightUsername
    
    static func fromHTTPCode(statusCode: Int?) -> RequestStatus {
        guard let status = statusCode else {
            let reachable = NetworkReachabilityHelper.isReachable()
            return !reachable ? .noInternet : RequestStatus.error
        }
        
        var correctEnum: RequestStatus
        
        switch status {
        case 200, 201, 202, 204, 206, 304:
            correctEnum = .success
        case 400:
            correctEnum = .badRequest
        case 401:
            correctEnum = .shouldRelogin
        case 403:
            correctEnum = .tokenError
        case 404:
            correctEnum = .notFound
        case 405, 409:
            correctEnum = .deniedForEver
        default:
            correctEnum = .error
        }
        
        if correctEnum == .error && !NetworkReachabilityHelper.isReachable() {
            correctEnum = .noInternet
        }
        
        return correctEnum
    }
}
