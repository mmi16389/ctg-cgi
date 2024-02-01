//
//  UserDefaultManager.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class UserDefaultManager {
    
    static let shared = {
        return UserDefaultManager()
    }()
    
    private var defaults = UserDefaults.standard
    
    private init() {
        
    }
    
    func clear() {
        guard let domainName = Bundle.main.bundleIdentifier else {
            return
        }
        
        defaults.removePersistentDomain(forName: domainName)
    }
    
    func logout() {
        neverAskCodes = []
        lastConfigurationRequestDate = nil
        lastTaskListRequestDate = nil
        lastUserRequestDate = nil
        lastReferentialRequestDate = nil
        lastFavoriteListRequestDate = nil
        lastNotificationRequestDate = nil
        removePushNotification()
    }
    
    func removePushNotification() {
        notificationPushEventTitle = nil
        notificationPushEventMessage = nil
        notificationPushEventTaskId = nil
    }
    
    var neverAskCodes: [DialogCode] {
        get {
            if let value = defaults.object(forKey: "neverAskCodes") as? [Int] {
                let dialogCodes = value.flatMap {
                    return DialogCode(rawValue: $0)
                }
                return dialogCodes
            }
            return []
        }
        set (aNewValue) {
            let intValues = aNewValue.map { $0.rawValue }
            defaults.set(intValues, forKey: "neverAskCodes")
        }
    }
    
    var notificationPushPreference: [Constant.Notification.Code] {
        get {
            if let value = defaults.object(forKey: "notificationPushPreference") as? [Int] {
                let dialogCodes = value.compactMap {
                    return Constant.Notification.Code(rawValue: $0)
                }
                return dialogCodes
            }
            return []
        }
        set (aNewValue) {
            let intValues = aNewValue.map { $0.rawValue }
            defaults.set(intValues, forKey: "notificationPushPreference")
        }
    }
    
    var appConfiguration: AppDynamicConfiguration? {
        get {
            if let data = UserDefaults.standard.value(forKey: "appConfiguration") as? Data {
                return try? PropertyListDecoder().decode(AppDynamicConfiguration.self, from: data)
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                defaults.set(try? PropertyListEncoder().encode(aNewValue), forKey: "appConfiguration")
            } else {
                defaults.removeObject(forKey: "appConfiguration")
            }
        }
    }
    
    var mapConfiguration: AppDynamicMapConfiguration? {
        get {
            if let data = UserDefaults.standard.value(forKey: "mapConfiguration") as? Data {
                return try? PropertyListDecoder().decode(AppDynamicMapConfiguration.self, from: data)
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                defaults.set(try? PropertyListEncoder().encode(aNewValue), forKey: "mapConfiguration")
            } else {
                defaults.removeObject(forKey: "mapConfiguration")
            }
        }
    }
    
    var lastConfigurationRequestDate: Date? {
        get {
            if let value = defaults.object(forKey: "lastConfigurationRequestDate") as? Date {
                return value
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "lastConfigurationRequestDate")
        }
    }
    
    var lastTaskListRequestDate: Date? {
        get {
            if let value = defaults.object(forKey: "lastTaskListRequestDate") as? Date {
                return value
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "lastTaskListRequestDate")
        }
    }
    
    var lastFavoriteListRequestDate: Date? {
        get {
            if let value = defaults.object(forKey: "lastFavoriteListRequestDate") as? Date {
                return value
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "lastFavoriteListRequestDate")
        }
    }
    
    var lastNotificationRequestDate: Date? {
        get {
            if let value = defaults.object(forKey: "lastNotificationRequestDate") as? Date {
                return value
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "lastNotificationRequestDate")
        }
    }
    
    var lastReferentialRequestDate: Date? {
        get {
            if let value = defaults.object(forKey: "lastReferentialRequestDate") as? Date {
                return value
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "lastReferentialRequestDate")
        }
    }
    
    var lastUserRequestDate: Date? {
        get {
            if let value = defaults.object(forKey: "lastUserRequestDate") as? Date {
                return value
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "lastUserRequestDate")
        }
    }
    
    var notificationPushEventTitle: String? {
        get {
            if let notificationPushEventTitleUserDefault = defaults.object(forKey: "notificationPushEventTitle") as? String {
                return notificationPushEventTitleUserDefault
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "notificationPushEventTitle")
        }
    }
    
    var notificationPushEventMessage: String? {
        get {
            if let notificationPushEventTitleUserDefault = defaults.object(forKey: "notificationPushEventMessage") as? String {
                return notificationPushEventTitleUserDefault
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "notificationPushEventMessage")
        }
    }
    
    var notificationPushEventTaskId: Int? {
        get {
            if let notificationPushEventTitleUserDefault = defaults.value(forKey: "notificationPushEventTaskId") as? Int {
                return notificationPushEventTitleUserDefault
            }
            return nil
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "notificationPushEventTaskId")
        }
    }
    
    var isSessionExpired: Bool {
        get {
            if let isSessionExpired = defaults.value(forKey: "isSessionExpired") as? Bool {
                return isSessionExpired
            }
            return false
        }
        set (aNewValue) {
            defaults.set(aNewValue, forKey: "isSessionExpired")
        }
    }
}
