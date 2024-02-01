//
//  InterventionTypeViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/25/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class InterventionTypeViewModel: Comparable {
    static func == (lhs: InterventionTypeViewModel, rhs: InterventionTypeViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: InterventionTypeViewModel, rhs: InterventionTypeViewModel) -> Bool {
        let value = lhs.name.caseInsensitiveCompare(rhs.name)
        guard value != .orderedSame else {
            return false
        }
        return value == .orderedAscending
    }
    
    let id: Int
    let name: String
    let urgent: Bool
    let estimatedDurationSec: TimeInterval
    let domain: DomainViewModel?
    
    init(id: Int, name: String, urgent: Bool, estimatedDurationSec: TimeInterval, domain: DomainViewModel? = nil) {
        self.id = id
        self.name = name
        self.urgent = urgent
        self.estimatedDurationSec = estimatedDurationSec
        self.domain = domain
    }
}

extension InterventionTypeViewModel: Convertible {
    
    static func from(db: InterventionType) -> InterventionTypeViewModel? {
        guard let name = db.name else {
            return nil
        }
        
        let domain = DomainViewModel.from(db: db.domain)
        
        return InterventionTypeViewModel(id: Int(db.id),
                                         name: name,
                                         urgent: db.isUrgent,
                                         estimatedDurationSec: db.estimatedDurationSec,
                                         domain: domain)
    }
}

extension InterventionTypeViewModel: ModalSelectListItemsDataSource {
    var displayableTitle: String {
        return self.name
    }
    
    var displayableSubtitle: String? {
        return nil
    }
    var displayableAnnotation: String? {
        return nil
    }
}
