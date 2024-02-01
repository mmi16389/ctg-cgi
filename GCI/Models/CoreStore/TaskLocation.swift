//
//  TaskLocation.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension TaskLocation: JSONParcelable {
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> TaskLocation {
        
        let idToFind = json["point"].stringValue
        
        var dbObject = try? transaction.fetchOne(
            From<TaskLocation>()
                .where(\.point == idToFind)
        )
        
        if dbObject == nil {
            dbObject = transaction.create(Into<TaskLocation>())
        }
        dbObject?.point = idToFind
        dbObject?.update(fromJSON: json, inTransaction: transaction)
        return dbObject!
    }
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.point = json["point"].stringValue
        self.address = json["address"].stringValue
        self.srid = json["srid"].int32Value
        self.comment = json["comment"].stringValue
        
    }
    
}
