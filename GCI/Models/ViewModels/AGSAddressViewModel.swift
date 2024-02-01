//
//  AGSAddressViewModel.swift
//  GCI
//
//  Created by Anthony Chollet on 07/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

class AGSAddressViewModel {

    let address: String
    let city: String
    let longLabel: String
    
    init(address: String, city: String, longLabel: String) {
        self.address = address
        self.city = city
        self.longLabel = longLabel
    }
}

extension AGSAddressViewModel: Convertible {
    static func from(db: JSON) -> AGSAddressViewModel? {
        
        guard let address = db["Address"].string,
        let city = db["City"].string,
        let longLabel = db["Match_addr"].string else {
            return nil
        }
        
        return AGSAddressViewModel(address: address,
                                   city: city,
                                   longLabel: longLabel)
    }
}
