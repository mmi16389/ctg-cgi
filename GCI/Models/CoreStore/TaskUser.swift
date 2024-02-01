//
//  TaskUser.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension TaskUser: JSONParcelable {
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> TaskUser {
        
        let idToFind = json["id"].stringValue
        
        var dbObject = try? transaction.fetchOne(
            From<TaskUser>()
                .where(\.id == idToFind)
        )
        
        if dbObject == nil {
            dbObject = transaction.create(Into<TaskUser>())
        }
        dbObject?.id = idToFind
        dbObject?.update(fromJSON: json, inTransaction: transaction)
        return dbObject!
    }
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.firstname = json["firstname"].stringValue
        self.lastname = json["lastname"].stringValue
        self.roles = json["roles"].arrayValue.flatMap { $0.string }
        
    }
    
}
