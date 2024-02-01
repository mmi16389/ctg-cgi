//
//  ReferentialDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol ReferentialDataService {
    
    typealias InterventionTypeListCallback = (_ result: ViewModelResult<[InterventionTypeViewModel]>) -> Void
    typealias DomainListCallback = (_ result: ViewModelResult<[DomainViewModel]>) -> Void
    typealias ServiceListCallback = (_ result: ViewModelResult<[ServiceViewModel]>) -> Void
    typealias StateCallback = (_ result: UIResult) -> Void
    
    func updateReferential(completion: @escaping StateCallback)
    func allInterventionTypes(forNewTask: Bool, completion: @escaping InterventionTypeListCallback)
    func allDomains(forNewTask: Bool, completion: @escaping DomainListCallback)
    func allServices(completion: @escaping ServiceListCallback)
}
