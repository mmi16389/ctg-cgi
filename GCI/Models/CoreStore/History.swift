//
//  History.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension History: JSONParcelable {
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> History {
        
        let idToFind = json["id"].int64Value
        
        var dbObject = try? transaction.fetchOne(
            From<History>()
                .where(\.id == idToFind)
        )
        
        if dbObject == nil {
            dbObject = transaction.create(Into<History>())
        }
        dbObject?.id = idToFind
        dbObject?.update(fromJSON: json, inTransaction: transaction)
        return dbObject!
    }
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        guard let newDate = json["date"].networkDate else {
            return
        }
        
        self.date = newDate
        self.name = json["name"].stringValue
        self.comment = json["comment"].stringValue
        self.statusChangedFor = json["statusChangedFor"].int16Value
        
        self.user = TaskUser.findOrCreate(fromJSON: json["user"], inTransaction: transaction)
        
    }
}
