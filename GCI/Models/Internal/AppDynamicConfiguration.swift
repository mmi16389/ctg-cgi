//
//  AppConfiguration.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import ArcGIS
import Alamofire
import AlamofireImage

struct AppDynamicConfiguration: Encodable, Decodable {
    
    private static var shared: AppDynamicConfiguration?
    
    static func current() -> AppDynamicConfiguration? {
        if let current = AppDynamicConfiguration.shared {
            // Gettin previous sync user
            return current
        }
        
        if let saved = UserDefaultManager.shared.appConfiguration {
            shared = saved
        }
        
        return shared
    }
    
    static func update(json: JSON) {
        let newConfig = AppDynamicConfiguration(json: json)
        
        if shared == nil || shared != newConfig {
            UserDefaultManager.shared.appConfiguration = newConfig
            shared = newConfig
            NotificationCenter.default.post(name: Notification.Name.appConfigurationChanged, object: nil)
        }
    }
    
    static func remove() {
        User.currentUser()?.logout()
        KeychainManager.shared.clear()
        UserDefaultManager.shared.clear()
        shared = nil
    }
    
    let loginUrl: String
    let logoutUrl: String
    let refreshUrl: String
    let forgotUrl: String?
    let ssoClientId: String
    let apiUrl: String
    
    let logoUrl: String
    let mainColorHexa: String
    var mainColor: UIColor {
        return UIColor(hex: mainColorHexa)
    }
    
    let mapProjection: Int
    let mapBound: String
    var mapBoundPolygon: AGSPolygon? {
        return mapBound.wktPolygon?.toPolygon(withSrid: mapProjection)
    }
    let mapBaseKey: String
    let mapDataUrl: String
    let mapLayerUrl: String
    let mapExportUrl: String
    let mapProxyUrl: String
    let mapZoom: Int
    let mapZoneMinimalZoom: Int
    let mapShouldDisplayZones: Bool
    let mapUpdatedDate: Date
    let geocodingServiceUrl: String?
    
    let notificationSenderId: String
    let notificationHubName: String
    let notificationHubListenConnectionString: String
    
    private init(json: JSON) {
        logoUrl = json["ui"]["picture"].stringValue
        mainColorHexa = json["ui"]["mainColor"].stringValue
        
        apiUrl = json["dns"]["webservice"].stringValue
        
        loginUrl = json["dns"]["sso"]["login"].stringValue
        logoutUrl = json["dns"]["sso"]["logout"].stringValue
        refreshUrl = json["dns"]["sso"]["refresh"].stringValue
        forgotUrl = json["dns"]["sso"]["forgot"].string
        ssoClientId = json["dns"]["sso"]["clientId"].stringValue
        
        geocodingServiceUrl = json["map"]["geocodingServiceUrl"].string
        mapProxyUrl = json["map"]["proxy"].stringValue
        mapDataUrl = json["map"]["data"].stringValue
        mapLayerUrl = json["map"]["layer"].stringValue
        mapExportUrl = json["map"]["export"].stringValue
        mapBound = json["map"]["bound"].stringValue
        mapBaseKey = json["map"]["base"].stringValue
        mapProjection = json["map"]["srid"].int ?? Constant.Map.defaultProjection
        mapZoom = json["map"]["zoom"].int ?? Constant.Map.defaultZoom
        mapZoneMinimalZoom = json["map"]["mapZoneMinimalZoom"].int ?? Constant.Map.defaultZoneMinimalZoom
        mapShouldDisplayZones = json["map"]["displayZones"].bool ?? true
        if let dateStr = json["map"]["updatedDate"].string {
            mapUpdatedDate = DateHelper.requestDateFormater.date(from: dateStr) ?? Date(timeIntervalSince1970: 0)
        } else {
            mapUpdatedDate = Date(timeIntervalSince1970: 0)
        }
        
        notificationHubName = json["notification"]["hubName"].stringValue
        notificationHubListenConnectionString = json["notification"]["hubListenConnectionString"].stringValue
        notificationSenderId = json["notification"]["senderId"].stringValue
    }
}

extension AppDynamicConfiguration: Equatable {
    
    static func == (lhs: AppDynamicConfiguration, rhs: AppDynamicConfiguration) -> Bool {
        return lhs.logoUrl == rhs.logoUrl &&
            lhs.mainColorHexa == rhs.mainColorHexa &&
            lhs.apiUrl == rhs.apiUrl &&
            lhs.loginUrl == rhs.loginUrl &&
            lhs.logoutUrl == rhs.logoutUrl &&
            lhs.refreshUrl == rhs.refreshUrl &&
            lhs.forgotUrl == rhs.forgotUrl &&
            lhs.ssoClientId == rhs.ssoClientId &&
            lhs.mapProxyUrl == rhs.mapProxyUrl &&
            lhs.mapDataUrl == rhs.mapDataUrl &&
            lhs.mapLayerUrl == rhs.mapLayerUrl &&
            lhs.mapExportUrl == rhs.mapExportUrl &&
            lhs.mapBound == rhs.mapBound &&
            lhs.mapBaseKey == rhs.mapBaseKey &&
            lhs.mapProjection == rhs.mapProjection &&
            lhs.mapZoom == rhs.mapZoom &&
            lhs.mapZoneMinimalZoom == rhs.mapZoneMinimalZoom &&
            lhs.mapShouldDisplayZones == rhs.mapShouldDisplayZones &&
            lhs.mapUpdatedDate == rhs.mapUpdatedDate &&
            lhs.notificationHubName == rhs.notificationHubName &&
            lhs.notificationHubListenConnectionString == rhs.notificationHubListenConnectionString &&
            lhs.notificationSenderId == rhs.notificationSenderId
    }
}
