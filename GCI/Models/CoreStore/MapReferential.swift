//
//  MapReferential.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension MapReferential {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.name = json["name"].stringValue
        
        let idList = json["zoneList"].arrayValue.map { $0.int64Value }
        let predicate = NSPredicate(format: "id IN %@", idList)
        let objectLists = try? transaction.fetchAll(
            From<Zone>(),
            Where<Zone>(predicate)
        )
        self.zones = NSSet(array: objectLists ?? [])
        
    }
}
