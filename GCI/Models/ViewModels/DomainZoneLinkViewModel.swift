//
//  DomainZoneLinkViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class DomainZoneLinkViewModel {
    
    let zone: ZoneViewModel
    let defaultService: ServiceViewModel
    let linkedServices: [ServiceViewModel]
    
    init(zone: ZoneViewModel, defaultService: ServiceViewModel, linkedServices linkedServicesOpt: [ServiceViewModel]? = nil) {
        self.zone = zone
        self.defaultService = defaultService
        self.linkedServices = linkedServicesOpt ?? []
    }
}

extension DomainZoneLinkViewModel: Convertible {
    
    static func from(db: DomainZoneLink) -> DomainZoneLinkViewModel? {
        guard let zone = ZoneViewModel.from(db: db.relatedZone),
             let defaultService = ServiceViewModel.from(db: db.defaultService) else {
            return nil
        }
        
        let serviceListDB = db.availableServices?.allObjects as? [Service] ?? []
        let serviceList = ServiceViewModel.from(dbList: serviceListDB)
        
        return DomainZoneLinkViewModel(zone: zone,
                                       defaultService: defaultService,
                                       linkedServices: serviceList)
    }
}
