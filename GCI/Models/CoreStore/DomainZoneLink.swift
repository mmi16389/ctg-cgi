//
//  DomainZone.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension DomainZoneLink: JSONParcelable {
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> DomainZoneLink {
        
        let zoneId = json["zoneId"].stringValue
        let defaultServiceId = json["defaultService"].stringValue
        
        let predicate = NSPredicate(format: "relatedZone.id == %d && defaultService.id == %d", zoneId, defaultServiceId)
        var dbObject = try? transaction.fetchOne(
            From<DomainZoneLink>(),
            Where<DomainZoneLink>(predicate)
        )
        
        if dbObject == nil {
            dbObject = transaction.create(Into<DomainZoneLink>())
        }
        dbObject?.update(fromJSON: json, inTransaction: transaction)
        return dbObject!
    }
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.relatedZone = try? transaction.fetchOne(
            From<Zone>()
                .where(\.id == json["zoneId"].int64Value)
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
    }
    
}
