//
//  NotificationDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class NotificationDataServiceImpl: NSObject, NotificationDataService {
    
    var internalApiService: NotificationAPIService?
    var internalLoginDataService: LoginDataService?
    
    override init() {
        super.init()
    }
    
    func apiService() -> NotificationAPIService {
        if internalApiService == nil {
            self.internalApiService = NotificationAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func loginService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func subscribe(completionHanlder: @escaping NotificationDataService.StatusCallback) {
        guard !KeychainManager.shared.isRegisteredToAzureMicrosoftPush else {
            // Is already registered to Microsoft so sending token online
            self.subscribeToBackend(completionHanlder: completionHanlder)
            return
        }
        
        guard let conf = AppDynamicConfiguration.current(),
            let deviceToken = KeychainManager.shared.pushToken,
            let user = User.currentUser() else {
            completionHanlder(.failed(.denied))
            return
        }
        let hub = SBNotificationHub(connectionString: conf.notificationHubListenConnectionString, notificationHubPath: conf.notificationHubName)
        
        let tagSet = Set<String>([
            "\(Constant.Notification.Tags.user)\(user.id)",
            "\(Constant.Notification.Tags.token)\(deviceToken.hexaTokenLimitedString)"
            ])
        
        hub?.registerNative(withDeviceToken: deviceToken, tags: tagSet, completion: { (errorOtp) in
            print("Push Azure register with possible error --> \(String(describing: errorOtp)) ")
            if errorOtp == nil {
                KeychainManager.shared.isRegisteredToAzureMicrosoftPush = true
                self.subscribeToBackend(completionHanlder: completionHanlder)
            } else {
                KeychainManager.shared.isRegisteredToAzureMicrosoftPush = false
                completionHanlder(.failed(.error))
            }
        })
    }
    
    private func subscribeToBackend(completionHanlder: @escaping NotificationDataService.StatusCallback) {
        guard let deviceToken = KeychainManager.shared.pushToken else {
            completionHanlder(.failed(.denied))
            return
        }
        
        self.loginService().makeSecureAPICall {
            
            self.apiService().register(token: deviceToken.hexaTokenLimitedString, completionHandler: { (requestStatus) in
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.subscribeToBackend(completionHanlder: completionHanlder)
                    return
                } else if requestStatus == .success {
                    
                   self.refreshSubscription(completionHanlder: completionHanlder)
                    
                } else {
                    DispatchQueue.main.async {
                        completionHanlder(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
            
        }
        
    }
    
    func unsubscribe(completionHanlder: @escaping NotificationDataService.StatusCallback) {
        guard let deviceToken = KeychainManager.shared.pushToken else {
            completionHanlder(.failed(.denied))
            return
        }
        self.apiService().unregister(token: deviceToken.hexaTokenLimitedString) { (requestStatus) in
            if requestStatus == .success {
                
                self.refreshSubscription(completionHanlder: completionHanlder)
                
            } else {
                DispatchQueue.main.async {
                    completionHanlder(.failed(ViewModelError.from(networkRequest: requestStatus)))
                }
            }
        }
        
        guard let conf = AppDynamicConfiguration.current() else {
            return
        }
        let hub = SBNotificationHub(connectionString: conf.notificationHubListenConnectionString, notificationHubPath: conf.notificationHubName)
        
        try? hub?.unregisterNative() // Trying to unregister
        KeychainManager.shared.isRegisteredToAzureMicrosoftPush = false
    }
    
    func refreshSubscription(completionHanlder: @escaping NotificationDataService.StatusCallback) {
        DispatchQueue.global().async {
            var shouldRefresh = true
            let lastDateFetchOpt = UserDefaultManager.shared.lastNotificationRequestDate
            if let lastDateFetch = lastDateFetchOpt {
                let diff = Date().timeIntervalSince(lastDateFetch)
                shouldRefresh = diff > Constant.API.Durations.fetchDelayNotification
            }
            
            if shouldRefresh {
                
                self.loginService().makeSecureAPICall {
                    
                    self.apiService().getSubscription(completionHandler: { (newInts, requestStatus) in
                        
                        if requestStatus == .shouldRelogin {
                            User.currentUser()?.invalidateToken()
                            self.refreshSubscription(completionHanlder: completionHanlder)
                            return
                        } else if requestStatus == .noInternet {
                            DispatchQueue.main.async {
                                completionHanlder(.failed(.noNetwork))
                            }
                            return
                        } else if requestStatus == .success {
                            
                            let newCodeList = newInts.compactMap {
                                return Constant.Notification.Code(rawValue: $0)
                            }
                            
                            UserDefaultManager.shared.notificationPushPreference = newCodeList
                            DispatchQueue.main.async {
                                completionHanlder(.success)
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                completionHanlder(.failed(ViewModelError.from(networkRequest: requestStatus)))
                            }
                        }
                        
                    })
                }
            } else {
                DispatchQueue.main.async {
                    completionHanlder(.success)
                }
            }
        }
    }
    
    func updateSubscription(withNotificationCode codes: [Constant.Notification.Code], completionHanlder: @escaping NotificationDataService.StatusCallback) {
        self.loginService().makeSecureAPICall {
            
            let intList = codes.map {
                $0.rawValue
            }
            
            self.apiService().updateSubscription(subscriptionList: intList, completionHandler: { (newList, requestStatus) in
                
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.updateSubscription(withNotificationCode: codes, completionHanlder: completionHanlder)
                    return
                } else if requestStatus == .success {
                    let newCodeList = newList.compactMap {
                        return Constant.Notification.Code(rawValue: $0)
                    }
                    
                    UserDefaultManager.shared.notificationPushPreference = newCodeList
                    completionHanlder(.success)
                    
                } else {
                    DispatchQueue.main.async {
                        completionHanlder(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
        }
    }
    
}
