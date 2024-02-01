//
//  Domain.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension Domain {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.name = json["name"].stringValue
        self.useMap = json["useMap"].boolValue
        self.usePatrimony = json["usePatrimony"].boolValue
        self.idForPatrimony = json["idPatrimony"].int64Value
        
        self.mapReferential = try? transaction.fetchOne(
            From<MapReferential>()
                .where(\.id == json["mapId"].int64Value)
        )
        
        self.defaultService = try? transaction.fetchOne(
            From<Service>()
                .where(\.id == json["defaultService"].int64Value)
        )
        
        let availableServicesIdList = json["linkedServices"].arrayValue.map { $0.int64Value }
        let predicate = NSPredicate(format: "id IN %@", availableServicesIdList)
        let availableServicesDBList = try? transaction.fetchAll(
            From<Service>(),
            Where<Service>(predicate)
        )
        self.availableServices = NSSet(array: availableServicesDBList ?? [])
        
        let stepsArray = DomainZoneLink.findOrCreate(fromJSON: json["zoneList"].arrayValue, inTransaction: transaction)
        self.zones = NSSet(array: stepsArray)
    }
}
