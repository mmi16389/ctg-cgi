//
//  NetworkReachabilityHelper.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Reachability

class NetworkReachabilityHelper {
    
    static func isReachable() -> Bool {
        
        let reachability = try? Reachability(hostname: Constant.API.baseUrl)
        if reachability == nil {
            // The server is not reachable
            return false
        }
        if let connection = reachability?.connection, connection == .unavailable {
            // The server is not reachable
            return false
        }
        return true
    }
}
