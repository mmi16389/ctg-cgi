//
//  ReferentialDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ReferentialDataServiceImpl: NSObject, ReferentialDataService {
    
    var internalDaoService: ReferentialDaoService?
    var internalApiService: ReferentialAPIService?
    var internalLoginDataService: LoginDataService?
    
    override init() {
        super.init()
    }
    
    func daoService() -> ReferentialDaoService {
        if internalDaoService == nil {
            self.internalDaoService = ReferentialDaoServiceImpl()
        }
        return internalDaoService!
    }
    
    func apiService() -> ReferentialAPIService {
        if internalApiService == nil {
            self.internalApiService = ReferentialAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func loginService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func updateReferential(completion: @escaping ReferentialDataService.StateCallback) {
        self.daoService().allMapZone { mapZone in
            
            let alreadyKnowsZonesIds = mapZone.zones.map { Int($0.id) }
            let alreadyKnowsMapsIds = mapZone.maps.map { Int($0.id) }
            
            self.loginService().makeSecureAPICall {
             
                self.apiService().referention(withAlreadyKnowMaps: alreadyKnowsMapsIds, andwithAlreadyKnowZones: alreadyKnowsZonesIds, completion: { (jsonOpt, requestStatus) in
                    
                    if requestStatus == .shouldRelogin {
                        User.currentUser()?.invalidateToken()
                        self.updateReferential(completion: completion)
                        return
                    } else if requestStatus == .noInternet {
                        DispatchQueue.main.async {
                            completion(.failed(.noNetwork))
                        }
                        return
                    } else if requestStatus == .success {
                        
                        if let json = jsonOpt {
                            
                            self.daoService().saveResponses(fromJson: json, completion: { (taskListUpdated) in
                                
                                DispatchQueue.main.async {
                                    completion(.success)
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
                })
            }
        }
    }
    
    func allInterventionTypes(forNewTask: Bool, completion: @escaping InterventionTypeListCallback) {
        self.daoService().allInterventionTypes { (objectList) in
            InterventionTypeViewModel.from(dbList: objectList, completion: { (viewModels) in
                if forNewTask {
                    var authorizedIntervention: [InterventionTypeViewModel] = []
                    viewModels.forEach { interventionType in
                        if let domain = interventionType.domain {
                            if let defaultService = domain.defaultService,
                               defaultService.permissions.contains(.createtask) {
                                authorizedIntervention.append(interventionType)
                            } else {
                                interventionType.domain?.zoneList.forEach({ zone in
                                    if zone.defaultService.permissions.contains(.createtask) {
                                        authorizedIntervention.append(interventionType)
                                    }
                                })
                            }
                        }
                    }
                    
                    completion(.value(authorizedIntervention.sorted()))
                } else {
                    completion(.value(viewModels.sorted()))
                }
            })
        }
    }
    
    func allDomains(forNewTask: Bool, completion: @escaping DomainListCallback) {
        self.daoService().allDomains { (objectList) in
            DomainViewModel.from(dbList: objectList, completion: { (viewModels) in
                if forNewTask {
                    var authorizedDomains: [DomainViewModel] = []
                    viewModels.forEach { domain in
                        if let defaultService = domain.defaultService,
                           defaultService.permissions.contains(.createtask) {
                            authorizedDomains.append(domain)
                        } else {
                            domain.zoneList.forEach({ zone in
                                if zone.defaultService.permissions.contains(.createtask) {
                                    authorizedDomains.append(domain)
                                }
                            })
                        }
                    }
                    
                    completion(.value(authorizedDomains.sorted()))
                } else {
                    completion(.value(viewModels.sorted()))
                }
            })
        }
    }
    
    func allServices(completion: @escaping ServiceListCallback) {
        self.daoService().allServices { (objectList) in
            ServiceViewModel.from(dbList: objectList, completion: { (viewModels) in
                completion(.value(viewModels.sorted()))
            })
        }
        
    }
    
}
