//
//  ViewModelResult.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

enum ViewModelResult<VALUE> {
    case value(VALUE)
    case failed(ViewModelError)
}

enum UIResult {
    case success
    case failed(ViewModelError)
}

enum ViewModelResultCachable<VALUE> {
    case cached(VALUE)
    case value(VALUE)
    case failed(ViewModelError)
}

enum ViewModelError {
    case error
    case denied
    case noNetwork
    case offlineNotAuthorized
    case canceled
    case noAddressFound
    case notRightUsername
    
    static func from(networkRequest request: RequestStatus) -> ViewModelError {
        switch request {
        case .noInternet:
            return .noNetwork
        case .deniedForEver, .badRequest:
            return .denied
        case .tokenError:
            return .notRightUsername
        default:
            return .error
        }
    }
}
