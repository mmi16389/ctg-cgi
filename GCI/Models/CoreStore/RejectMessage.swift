//
//  RejectMessage.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension RejectMessage {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.title = json["title"].stringValue
        self.content = json["content"].stringValue
        self.shortTitle = json["shortTitle"].stringValue
        
    }
}
