//
//  InterventionType.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension InterventionType {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.name = json["name"].stringValue
        self.isUrgent = json["isUrgent"].boolValue
        self.estimatedDurationSec = json["estimatedDurationSec"].doubleValue
        
        self.domain = try? transaction.fetchOne(
            From<Domain>()
                .where(\.id == json["domain"].int64Value)
        )
        
    }
}
