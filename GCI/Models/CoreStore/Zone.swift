//
//  Zone.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension Zone {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.name = json["name"].stringValue
        self.wkt = json["wkt"].stringValue
        self.colorHexa = json["color"].stringValue
        self.srid = json["srid"].int32Value
        
    }
}
