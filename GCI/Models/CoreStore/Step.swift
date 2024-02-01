//
//  Step.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension Step: JSONParcelable {
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> Step {
        
        let idToFind = json["id"].int64Value
        
        var step = try? transaction.fetchOne(
            From<Step>()
                .where(\.id == idToFind)
        )
        
        if step == nil {
            step = transaction.create(Into<Step>())
        }
        step?.id = idToFind
        step?.update(fromJSON: json, inTransaction: transaction)
        return step!
    }
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        guard let newDate = json["date"].networkDate else {
            return
        }
        
        self.date = newDate
        self.action = json["action"].int16Value
        self.title = json["title"].stringValue
        self.desc = json["description"].stringValue
        
        if json["attachement"].exists() {
            self.attachment = Attachment.findOrCreate(fromJSON: json["attachement"], inTransaction: transaction)
        } else {
            self.attachment = nil
        }
        
        self.user = TaskUser.findOrCreate(fromJSON: json["user"], inTransaction: transaction)
    
    }
}
