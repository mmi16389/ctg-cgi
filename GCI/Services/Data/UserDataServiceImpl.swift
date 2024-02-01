//
//  UserDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class UserDataServiceImpl: NSObject, UserDataService {
    
    var internalDaoService: MessageDaoService?
    var internalApiService: UserAPIService?
    var internalLoginDataService: LoginDataService?
    var internalRefDaoService: ReferentialDaoService?
    
    override init() {
        super.init()
    }
    
    func daoService() -> MessageDaoService {
        if internalDaoService == nil {
            self.internalDaoService = MessageDaoServiceImpl()
        }
        return internalDaoService!
    }
    
    func apiService() -> UserAPIService {
        if internalApiService == nil {
            self.internalApiService = UserAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func loginService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func refDaoService() -> ReferentialDaoService {
        if internalRefDaoService == nil {
            self.internalRefDaoService = ReferentialDaoServiceImpl()
        }
        return internalRefDaoService!
    }
    
    func update(completion: @escaping UserDataService.StateCallback) {
        var shouldRefresh = true
        let lastDateFetchOpt = UserDefaultManager.shared.lastUserRequestDate
        if let lastDateFetch = lastDateFetchOpt {
            let diff = Date().timeIntervalSince(lastDateFetch)
            shouldRefresh = diff > Constant.API.Durations.fetchDelayUser
        }
        
        if shouldRefresh {
            self.loginService().makeSecureAPICall {
                self.apiService().user { (jsonOpt, requestStatus) in
                    
                    if requestStatus == .shouldRelogin {
                        User.currentUser()?.invalidateToken()
                        self.update(completion: completion)
                        return
                    } else if requestStatus == .noInternet {
                        DispatchQueue.main.async {
                            completion(.failed(.noNetwork))
                        }
                        return
                    } else if requestStatus == .success {
                        if let json = jsonOpt {
                            User.currentUser()?.id = json["id"].stringValue
                            User.currentUser()?.firstName = json["firstname"].stringValue
                            User.currentUser()?.lastName = json["lastname"].stringValue
                            User.currentUser()?.roles = json["roles"].arrayValue.flatMap { $0.string }
                            User.currentUser()?.save()
                            
                            self.refDaoService().savePermissionsResponses(fromJson: json["services"].arrayValue) { (_) in
                                User.currentUser()?.reloadPermissions()
                            }
                            
                            self.daoService().saveResponses(fromJson: json, completion: { (returned) in
                                if returned {
                                    UserDefaultManager.shared.lastUserRequestDate = Date()
                                }
                                DispatchQueue.main.async {
                                    completion(returned ? .success: .failed(.error))
                                }
                            })
                        } else {
                            DispatchQueue.main.async {
                                completion(.success)
                            }
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(.success)
            }
        }
    }
    
    func cancelMessages(completion: @escaping UserDataService.MessageCallbak) {
        self.daoService().allCancelMessages { (cancelMessages) in
            let models = (cancelMessages).flatMap {
                PrefilledMessageViewModel.from(cancelMessage: $0)
            }
            DispatchQueue.main.async {
                completion(models)
            }
        }
    }
    
    func rejectMessages(completion: @escaping UserDataService.MessageCallbak) {
        self.daoService().allRejectMessages { (dbObjectList) in
            let models = dbObjectList.flatMap {
                PrefilledMessageViewModel.from(rejectMessage: $0)
            }
            DispatchQueue.main.async {
                completion(models)
            }
        }
    }
}
