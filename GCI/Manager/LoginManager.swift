//
//  LoginManager.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class LoginManager: NSObject {

    typealias LoginViewModelCompletionHandler = (_ user: User?, _ error: ViewModelError?) -> Void

    var internalLoginDataService: LoginDataService?
    var internalNotificationDataService: NotificationDataService?
    
    func loginDataService() -> LoginDataService {
        if internalLoginDataService == nil {
            internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func notificationService() -> NotificationDataService {
        if internalNotificationDataService == nil {
            internalNotificationDataService = NotificationDataServiceImpl()
        }
        return internalNotificationDataService!
    }
    
    func authenticateUser(login: String, password: String, completionHandler: @escaping LoginViewModelCompletionHandler) {
        loginDataService().authenticateUser(login: login, password: password) { (result) in
            switch result {
            case .value(let user):
                
                SynchronizationService.shared.startDownSynchronization { (result) in
                    switch result {
                    case .success:
                        completionHandler(user, nil)
                        self.notificationService().subscribe {
                            print("[Notification] subscribe when user login with message \($0)")
                        }
                    case .noInternet:
                        User.currentUser()?.logout()
                        completionHandler(nil, .noNetwork)
                    default:
                        User.currentUser()?.logout()
                        completionHandler(nil, .denied)
                    }
                }
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
}
