//
//  User.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class User {
    
    private static var current: User?
    
    static func currentUser() -> User? {
        if let current = User.current {
            // Gettin previous sync user
            return current
        }
        
        if let userId = KeychainManager.shared.userId {
            
            // Gettin user from keychain
            let newUser = User(id: userId)
            User.current = newUser
            return newUser
        }
        
        return nil
    }
    
    static func login(id: String, webToken: String, webRefreshToken: String, webRefreshExpireInSeconds: Int) -> User {
        let newUser = User(id: id)
        
        newUser.refreshToken(webToken: webToken, webRefreshToken: webRefreshToken, webRefreshExpireInSeconds: webRefreshExpireInSeconds)
        
        newUser.save()
        return newUser
    }
    
    private let permissionSemaphore =  DispatchSemaphore(value: 1)
    var referentialDaoService = ReferentialDaoServiceImpl()
    let taskDaoService = TaskDAOServiceImpl()
    let messagesDaoService = MessageDaoServiceImpl()
    let attachmentDataService = AttachmentDataServiceImpl()
    let workflowDaoService = WorkflowDAOServiceImpl()
    let createdTaskDaoService = CreatedTaskDAOServiceImpl()
    let createdStepDaoService = CreatedStepDAOServiceImpl()
    let favoriteDAOService = FavoriteDAOServiceImpl()
    let notificationDataService = NotificationDataServiceImpl()
    
    var webToken: String?
    var webRefreshToken: String?
    var webTokenExpireDate: Date?
    var id: String
    var firstName: String?
    var lastName: String?
    var roles = [String]()
    var permissions = [ServiceViewModel.Permission]()
    
    var fullname: String {
        var fullname = ""
        
        if let firstName = self.firstName, !firstName.isEmpty {
            fullname += firstName
            fullname += " "
        }
        
        fullname += lastName ?? ""
        
        if fullname.isEmpty {
            fullname += id
        }
        return fullname
    }
    
    var tokenIsValid: Bool {
        guard let expireDate = self.webTokenExpireDate else {
            return false
        }
        return expireDate.isInFuture
    }
    
    private init(id: String) {
        self.id = id
        
        if let keyChainValue = KeychainManager.shared.userWebToken {
            self.webToken = keyChainValue
        }
        
        if let keyChainValue = KeychainManager.shared.userWebRefreshToken {
            self.webRefreshToken = keyChainValue
        }
        
        if let keyChainValue = KeychainManager.shared.userWebTokenExpireDate {
            self.webTokenExpireDate = keyChainValue
        }
        
        if let keyChainValue = KeychainManager.shared.userFirstName {
            self.firstName = keyChainValue
        }
        
        if let keyChainValue = KeychainManager.shared.userLastName {
            self.lastName = keyChainValue
        }
        
        self.roles = KeychainManager.shared.userRoles
        
        self.reloadPermissions()
    }
    
    func logout() {
        KeychainManager.shared.logout()
        UserDefaultManager.shared.logout()
        
        taskDaoService.deleteAll {
            print("[Logout] All tasks deleted : \($0) ")
        }
        messagesDaoService.clearAllMessages {
            print("[Logout] All messages deleted : \($0) ")
        }
        referentialDaoService.clearPermissions {
            print("[Logout] All permissions deleted : \($0) ")
        }
        referentialDaoService.deleteAll {
            print("[Logout] All referential deleted : \($0) ")
        }
        workflowDaoService.deleteAllPending {
            print("[Logout] All workflow deleted : \($0) ")
        }
        attachmentDataService.deleteAllFiles {
            print("[Logout] All attachment deleted : \($0) ")
        }
        createdTaskDaoService.deleteAll {
            print("[Logout] All createdTask deleted : \($0) ")
        }
        createdStepDaoService.deleteAll {
            print("[Logout] All createdStep deleted : \($0) ")
        }
        favoriteDAOService.deleteAll {
            print("[Logout] All favorite actions deleted : \($0) ")
        }
        notificationDataService.unsubscribe {
            print("[Logout] Notification unsubscribed with message : \($0) ")
        }
        
        UserDataFilter.unique.reset()
        
        User.current = nil
    }
    
    func refreshToken(webToken: String, webRefreshToken: String, webRefreshExpireInSeconds: Int) {
        self.webToken = webToken
        self.webRefreshToken = webRefreshToken
        let now = Date()
        let timeInterval = Double(webRefreshExpireInSeconds)
        let webTokenExpireDate = now.addingTimeInterval(timeInterval)
        self.webTokenExpireDate = webTokenExpireDate
    }
    
    func invalidateToken() {
        self.webTokenExpireDate = nil
    }
    
    func save() {
        KeychainManager.shared.userId = self.id
        KeychainManager.shared.userFirstName = self.firstName
        KeychainManager.shared.userLastName = self.lastName
        KeychainManager.shared.userRoles = self.roles
        KeychainManager.shared.userWebToken = self.webToken
        KeychainManager.shared.userWebRefreshToken = self.webRefreshToken
        KeychainManager.shared.userWebTokenExpireDate = self.webTokenExpireDate
        User.current = self
    }
    
    func reloadPermissions() {
        self.permissionSemaphore.wait()
        self.referentialDaoService.uniquePermissionCodes { (permissionsCodeInts) in
            self.permissions = permissionsCodeInts.flatMap {
                ServiceViewModel.Permission(rawValue: $0)
            }
            self.permissionSemaphore.signal()
        }
    }
    
    func isCategoryVisible(_ category: TaskCategory) -> Bool {
        permissionSemaphore.wait()
        let permissionsGranted = category.permissionsGranted
        let tmp =  permissionsGranted.contains {
            self.permissions.contains($0)
        }
        permissionSemaphore.signal()
        return tmp
    }
}
