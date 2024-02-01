//
//  AppDynamicMapConfiguration.swift
//  GCI
//
//  Created by Anthony Chollet on 21/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import ArcGIS

struct AppDynamicMapConfiguration: Encodable, Decodable {
    private static var shared: AppDynamicMapConfiguration?
    
    static func current() -> AppDynamicMapConfiguration? {
        if let current = AppDynamicMapConfiguration.shared {
            // Gettin previous sync user
            return current
        }
        
        if let saved = UserDefaultManager.shared.mapConfiguration {
            shared = saved
        }
        
        return shared
    }
    
    let user: String
    let password: String
    let licence: String
    
    static func update(json: JSON) {
        let newConfig = AppDynamicMapConfiguration(json: json)
        
        if shared == nil || shared != newConfig {
            UserDefaultManager.shared.mapConfiguration = newConfig
            shared = newConfig
            if let licence = AppDynamicMapConfiguration.current()?.licence {
                _ = try? AGSArcGISRuntimeEnvironment.setLicenseKey(licence)
            }
        }
    }
    
    private init(json: JSON) {
        user = json["exportTileUser"].stringValue
        password = json["exportTilePassword"].stringValue
        licence = json["licenseKey"].stringValue
    }
}

extension AppDynamicMapConfiguration: Equatable {
    static func == (lhs: AppDynamicMapConfiguration, rhs: AppDynamicMapConfiguration) -> Bool {
        return lhs.user == rhs.user &&
            lhs.password == rhs.password &&
            lhs.licence == rhs.licence
    }
}
