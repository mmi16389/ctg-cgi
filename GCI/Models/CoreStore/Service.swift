//
//  Service.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension Service {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.name = json["name"].stringValue
        if let type = json["type"].int16 {
            self.type = type
        } else {
            // If no type we use the default one
            self.type = Int16(ServiceViewModel.Family.standard.rawValue)
        }
        
    }
}
