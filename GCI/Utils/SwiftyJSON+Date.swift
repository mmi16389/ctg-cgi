//
//  SwiftyJSON+Date.swift
//  GCI
//
//  Created by Florian ALONSO on 5/15/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    
    var networkDate: Date? {
        return DateHelper.requestDateFormater.date(from: self.stringValue)
    }
}
