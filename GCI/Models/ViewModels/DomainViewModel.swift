//
//  DomainViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class DomainViewModel {
    let id: Int
    let title: String
    let useMap: Bool
    let usePatrimony: Bool
    let idPatrimony: Int64?
    let zoneList: [DomainZoneLinkViewModel]
    let defaultService: ServiceViewModel?
    let linkedServices: [ServiceViewModel]
    
    init(id: Int, title: String, useMap: Bool, usePatrimony: Bool, idPatrimony: Int64? = nil, zoneList: [DomainZoneLinkViewModel] = [], defaultService: ServiceViewModel? = nil, linkedServices: [ServiceViewModel] = []) {
        self.id = id
        self.title = title
        self.useMap = useMap
        self.usePatrimony = usePatrimony
        self.idPatrimony = idPatrimony
        self.zoneList = zoneList
        self.defaultService = defaultService
        self.linkedServices = linkedServices
    }
}

extension DomainViewModel: Comparable {
    static func < (lhs: DomainViewModel, rhs: DomainViewModel) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: DomainViewModel, rhs: DomainViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension DomainViewModel: Convertible {
    
    static func from(db: Domain) -> DomainViewModel? {        
        let zoneListDB = db.zones?.allObjects as? [DomainZoneLink] ?? []
        let zoneList = DomainZoneLinkViewModel.from(dbList: zoneListDB)
        let serviceListDB = db.availableServices?.allObjects as? [Service] ?? []
        let serviceList = ServiceViewModel.from(dbList: serviceListDB)
        let service = ServiceViewModel.from(db: db.defaultService)
        
        return DomainViewModel(id: Int(db.id),
                               title: db.name ?? "",
                               useMap: db.useMap,
                               usePatrimony: db.usePatrimony,
                               idPatrimony: db.idForPatrimony,
                               zoneList: zoneList,
                               defaultService: service,
                               linkedServices: serviceList)
    }
}

extension DomainViewModel: ModalSelectListItemsDataSource {
    var displayableTitle: String {
        return self.title
    }
    
    var displayableSubtitle: String? {
        return nil
    }
    var displayableAnnotation: String? {
        return nil
    }
}
