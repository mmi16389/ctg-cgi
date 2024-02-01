//
//  KeychainManager.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import KeychainSwift

class KeychainManager {
    
    static let shared = {
        return KeychainManager()
    }()
    
    lazy var keychain = {
        return KeychainSwift()
    }()
    
    private init() {
        
    }
    
    func logout() {
        userWebToken = nil
        userWebTokenExpireDate = nil
        userWebRefreshToken = nil
        userId = nil
        userFirstName = nil
        userLastName = nil
        userRoles = []
    }
    
    // Should not call this method. It's a workaround to clear keychain entries not cleared after app unistallation
    func clear() {
        keychain.clear()
    }
    
    // MARK: - App
    var licenceKey: String? {
        get {
            if let usernameKeychain = keychain.get("licenceKey") {
                return usernameKeychain
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                keychain.set(aNewValue, forKey: "licenceKey")
            } else {
                keychain.delete("licenceKey")
            }
        }
    }
    
    // MARK: - User    
    var userId: String? {
        get {
            if let usernameKeychain = keychain.get("userId") {
                return usernameKeychain
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                keychain.set(aNewValue, forKey: "userId")
            } else {
                keychain.delete("userId")
            }
        }
    }
    
    var userFirstName: String? {
        get {
            if let usernameKeychain = keychain.get("userFirstName") {
                return usernameKeychain
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                keychain.set(aNewValue, forKey: "userFirstName")
            } else {
                keychain.delete("userFirstName")
            }
        }
    }
    
    var userLastName: String? {
        get {
            if let usernameKeychain = keychain.get("userLastName") {
                return usernameKeychain
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                keychain.set(aNewValue, forKey: "userLastName")
            } else {
                keychain.delete("userLastName")
            }
        }
    }
    
    var userRoles: [String] {
        get {
            if let roleKeychain = keychain.get("userRoles") {
                return roleKeychain.split(separator: "|").map(String.init)
            }
            return []
        }
        set (aNewValueOpt) {
            keychain.set(aNewValueOpt.joined(separator: "|"), forKey: "userRoles")
        }
    }
    
    var userWebToken: String? {
        get {
            if let keychainValue = keychain.get("userWebToken") {
                return keychainValue
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                keychain.set(aNewValue, forKey: "userWebToken")
            } else {
                keychain.delete("userWebToken")
            }
        }
    }
    
    var userWebRefreshToken: String? {
        get {
            if let keychainValue = keychain.get("userWebRefreshToken") {
                return keychainValue
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                keychain.set(aNewValue, forKey: "userWebRefreshToken")
            } else {
                keychain.delete("userWebRefreshToken")
            }
        }
    }
    
    var userWebTokenExpireDate: Date? {
        get {
            if let keychainValue = keychain.get("webTokenExpireDateStr") {
                return DateHelper.requestDateFormater.date(from: keychainValue)
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                let aNewDate = DateHelper.requestDateFormater.string(from: aNewValue)
                keychain.set("\(aNewDate)", forKey: "webTokenExpireDateStr")
            } else {
                keychain.delete("webTokenExpireDateStr")
            }
        }
    }
    
    var pushToken: Data? {
        get {
            if let pushTokenKeychain = keychain.getData("pushToken") {
                return pushTokenKeychain
            }
            return nil
        }
        set (aNewValueOpt) {
            if let aNewValue = aNewValueOpt {
                keychain.set(aNewValue, forKey: "pushToken")
            } else {
                keychain.delete("pushToken")
            }
        }
    }
    
    var isRegisteredToAzureMicrosoftPush: Bool {
        get {
            if let pushTokenKeychain = keychain.getBool("isRegisteredToAzureMicrosoftPush") {
                return pushTokenKeychain
            }
            return false
        }
        set (aNewValue) {
            keychain.set(aNewValue, forKey: "isRegisteredToAzureMicrosoftPush")
        }
    }
}
