//
//  ConfigurationDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ConfigurationDataServiceImpl: NSObject, ConfigurationDataService {
    
    var internalApiService: ConfigurationAPIService?
    var internalLoginDataService: LoginDataService?
    
    override init() {
        super.init()
    }
    
    func apiService() -> ConfigurationAPIService {
        if internalApiService == nil {
            self.internalApiService = ConfigurationApiServiceImpl()
        }
        return internalApiService!
    }
    
    func loginDataService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func test(licence: String, completionHandler: @escaping ConfigurationDataService.RequestStatusCallback) {
        let sha256Licence = licence.sha256()
        KeychainManager.shared.licenceKey = sha256Licence
        
        apiService().configuration { (json, requestStatus) in
            if requestStatus != .success || json == nil {
                KeychainManager.shared.licenceKey = nil
                completionHandler(.failed(ViewModelError.from(networkRequest: requestStatus)))
                return
            }
            
            AppDynamicConfiguration.update(json: json!)
            DispatchQueue.main.async {
                guard let configuration = AppDynamicConfiguration.current() else {
                    completionHandler(.failed(.error))
                    return
                }
                completionHandler(.value(configuration))
            }
        }
    }
    
    func refresh(completionHandler: @escaping ConfigurationDataService.RequestStatusCallback) {
            DispatchQueue.global().async {
                var shouldRefresh = true
                let lastFetchOpt = UserDefaultManager.shared.lastConfigurationRequestDate
                if let lastFetch = lastFetchOpt {
                    shouldRefresh = Date().timeIntervalSince(lastFetch) > Constant.API.Durations.fetchDelayConfiguration
                }
                
                if shouldRefresh {
                    self.apiService().configuration { (jsonOpt, requestStatus) in
                        if requestStatus == .tokenError {
                            AppDynamicConfiguration.remove()
                            NotificationCenter.default.post(name: Notification.Name.licenceExpired, object: nil)
                            return
                        } else if requestStatus != .success || jsonOpt == nil {
                            DispatchQueue.main.async {
                                completionHandler(.failed(ViewModelError.from(networkRequest: requestStatus)))
                            }
                            return
                        }
                        
                        AppDynamicConfiguration.update(json: jsonOpt!)
                        DispatchQueue.main.async {
                            guard let configuration = AppDynamicConfiguration.current() else {
                                completionHandler(.failed(.error))
                                return
                            }
                            completionHandler(.value(configuration))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        guard let configuration = AppDynamicConfiguration.current() else {
                            completionHandler(.failed(.error))
                            return
                        }
                        completionHandler(.value(configuration))
                    }
                }
            }
    }
    
    func mapConfiguration(completionHandler: @escaping ConfigurationDataService.MapConfigCallback) {
        self.loginDataService().makeSecureAPICall {
            
            self.apiService().mapConfiguration({ (jsonOpt, requestStatus) in
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.mapConfiguration(completionHandler: completionHandler)
                    return
                } else if requestStatus != .success || jsonOpt == nil {
                    DispatchQueue.main.async {
                        completionHandler(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                    return
                }
                
                AppDynamicMapConfiguration.update(json: jsonOpt!)
                DispatchQueue.main.async {
                    guard let configuration = AppDynamicMapConfiguration.current() else {
                        completionHandler(.failed(.error))
                        return
                    }
                    completionHandler(.value(configuration))
                }
            })
        }
    }
}
