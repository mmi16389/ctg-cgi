//
//  File.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension Attachment: JSONParcelable {   
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> Attachment {
        let idToFind = json["uuid"].stringValue
        
        var attachment = try? transaction.fetchOne(
            From<Attachment>()
                .where(\.uuid == idToFind)
        )
        
        if attachment == nil {
            attachment = transaction.create(Into<Attachment>())
        }
        attachment?.uuid = idToFind
        attachment?.update(fromJSON: json, inTransaction: transaction)
        return attachment!
    }
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        self.uuid = json["uuid"].stringValue
        self.mimeType = json["mimeType"].stringValue
    }
    
}
