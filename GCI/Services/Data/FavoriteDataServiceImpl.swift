//
//  FavoriteDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class FavoriteDataServiceImpl: NSObject, FavoriteDataService {
    
    var internalDaoService: FavoriteDAOService?
    var internalApiService: FavoriteAPIService?
    var internalTaskDaoService: TaskDAOService?
    var internalLoginDataService: LoginDataService?
    
    override init() {
        super.init()
    }
    
    func daoService() -> FavoriteDAOService {
        if internalDaoService == nil {
            self.internalDaoService = FavoriteDAOServiceImpl()
        }
        return internalDaoService!
    }
    
    func apiService() -> FavoriteAPIService {
        if internalApiService == nil {
            self.internalApiService = FavoriteAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func loginService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func taskDaoService() -> TaskDAOService {
        if internalTaskDaoService == nil {
            self.internalTaskDaoService = TaskDAOServiceImpl()
        }
        return internalTaskDaoService!
    }
    
    func syncFavoritesFromServer(completionHanlder: @escaping FavoriteDataService.StatusCallback) {
        DispatchQueue.global().async {
            var shouldRefresh = true
            let lastDateFetchOpt = UserDefaultManager.shared.lastFavoriteListRequestDate
            if let lastDateFetch = lastDateFetchOpt {
                let diff = Date().timeIntervalSince(lastDateFetch)
                shouldRefresh = diff > Constant.API.Durations.fetchDelayFavorite
            }
            
            if shouldRefresh {
                
                self.loginService().makeSecureAPICall {
                    
                    self.apiService().favoriteList(completionHandler: { (taskIds, requestStatus) in
                        
                        if requestStatus == .shouldRelogin {
                            User.currentUser()?.invalidateToken()
                            self.syncFavoritesFromServer(completionHanlder: completionHanlder)
                            return
                        } else if requestStatus == .noInternet {
                            DispatchQueue.main.async {
                                completionHanlder(.failed(.noNetwork))
                            }
                            return
                        } else if requestStatus == .success {
                            
                            self.taskDaoService().setAllFavorites(byIds: taskIds, completion: { (success) in
                                DispatchQueue.main.async {
                                    if success {
                                        UserDefaultManager.shared.lastFavoriteListRequestDate = Date()
                                        completionHanlder(.success)
                                    } else {
                                        completionHanlder(.failed(.error))
                                    }
                                }
                            })
                            
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
    
    func setTaskAsFavorite(byTaskId taskId: Int, completionHanlder: @escaping FavoriteDataService.StatusCallback) {
        self.loginService().makeSecureAPICall {
            self.taskDaoService().setFavorite(byTaskId: taskId, isBecomingFavorite: true, completion: { (taskOpt) in
                guard taskOpt != nil else {
                    DispatchQueue.main.async {
                        completionHanlder(.failed(.error))
                    }
                    return
                }
                
                self.apiService().addAsFavorite(theTaskId: taskId, completionHandler: { (requestStatus) in
                    if requestStatus == .shouldRelogin {
                        User.currentUser()?.invalidateToken()
                        self.setTaskAsFavorite(byTaskId: taskId, completionHanlder: completionHanlder)
                        return
                    } else if requestStatus == .noInternet {
                        self.daoService().addToActionFavorite(forTaskId: taskId, isBecommingFavorite: true, completion: { (success) in
                            DispatchQueue.main.async {
                                if success {
                                    completionHanlder(.success)
                                } else {
                                    completionHanlder(.failed(.error))
                                }
                            }
                        })
                        return
                    } else if requestStatus == .success {
                        
                        self.daoService().delete(byTaskId: taskId, completion: { (success) in
                            DispatchQueue.main.async {
                                if success {
                                    completionHanlder(.success)
                                } else {
                                    completionHanlder(.failed(.error))
                                }
                            }
                        })
                        
                    } else {
                        DispatchQueue.main.async {
                            completionHanlder(.failed(ViewModelError.from(networkRequest: requestStatus)))
                        }
                    }
                })
                
            })
        }
    }
    
    func removeTaskAsFavorite(byTaskId taskId: Int, completionHanlder: @escaping FavoriteDataService.StatusCallback) {
        self.loginService().makeSecureAPICall {
            self.taskDaoService().setFavorite(byTaskId: taskId, isBecomingFavorite: false, completion: { (taskOpt) in
                guard taskOpt != nil else {
                    DispatchQueue.main.async {
                        completionHanlder(.failed(.error))
                    }
                    return
                }
                
                self.apiService().removeFromFavorite(theTaskId: taskId, completionHandler: { (requestStatus) in
                    if requestStatus == .shouldRelogin {
                        User.currentUser()?.invalidateToken()
                        self.setTaskAsFavorite(byTaskId: taskId, completionHanlder: completionHanlder)
                        return
                    } else if requestStatus == .noInternet {
                        self.daoService().addToActionFavorite(forTaskId: taskId, isBecommingFavorite: false, completion: { (success) in
                            DispatchQueue.main.async {
                                if success {
                                    completionHanlder(.success)
                                } else {
                                    completionHanlder(.failed(.error))
                                }
                            }
                        })
                        return
                    } else if requestStatus == .success {
                        
                        self.daoService().delete(byTaskId: taskId, completion: { (success) in
                            DispatchQueue.main.async {
                                if success {
                                    completionHanlder(.success)
                                } else {
                                    completionHanlder(.failed(.error))
                                }
                            }
                        })
                        
                    } else {
                        DispatchQueue.main.async {
                            completionHanlder(.failed(ViewModelError.from(networkRequest: requestStatus)))
                        }
                    }
                })
                
            })
        }
    }
    
    func forceSynchronize(actionFavorite: ActionFavoriteViewModel, completionHandler: @escaping FavoriteDataService.StatusCallback) {
        self.loginService().makeSecureAPICall {
            
            let generalCompletionHandler = { (requestStatus: RequestStatus) in
                
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.forceSynchronize(actionFavorite: actionFavorite, completionHandler: completionHandler)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completionHandler(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .deniedForEver {
                    DispatchQueue.main.async {
                        completionHandler(.success) // It's denied so validating it anyway
                    }
                    return
                } else if requestStatus == .success {
                    
                    self.daoService().delete(byTaskId: actionFavorite.taskId, completion: { (success) in
                        DispatchQueue.main.async {
                            if success {
                                completionHandler(.success)
                            } else {
                                completionHandler(.failed(.error))
                            }
                        }
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            }
        
            if actionFavorite.becommingFavorite {
                self.apiService().addAsFavorite(theTaskId: actionFavorite.taskId, completionHandler: generalCompletionHandler)
            } else {
                self.apiService().removeFromFavorite(theTaskId: actionFavorite.taskId, completionHandler: generalCompletionHandler)
                
            }
        }
    }
    
}
