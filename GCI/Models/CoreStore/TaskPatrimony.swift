//
//  TaskPatrimony.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension TaskPatrimony: JSONParcelable {
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> TaskPatrimony {
        
        let idToFind = json["id"].int64Value
        
        var dbObject = try? transaction.fetchOne(
            From<TaskPatrimony>()
                .where(\.id == idToFind)
        )
        
        if dbObject == nil {
            dbObject = transaction.create(Into<TaskPatrimony>())
        }
        dbObject?.id = idToFind
        dbObject?.update(fromJSON: json, inTransaction: transaction)
        return dbObject!
    }
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.key = json["key"].stringValue
        self.desc = json["description"].stringValue
        
    }
    
}
