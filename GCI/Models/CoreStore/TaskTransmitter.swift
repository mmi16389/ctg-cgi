//
//  TaskTransmiter.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension TaskTransmitter {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.firstname = json["firstname"].stringValue
        self.lastname = json["lastname"].stringValue
        self.civility = json["civility"].stringValue
        self.phone = json["phone"].stringValue
        self.email = json["email"].stringValue
        self.address = json["address"].stringValue
        
    }
    
}
