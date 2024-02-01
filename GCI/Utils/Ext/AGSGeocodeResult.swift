//
//  AGSGeocodeResult.swift
//  GCI
//
//  Created by Anthony on 20/01/2023.
//  Copyright © 2023 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

extension AGSGeocodeResult {
    func getAddressToSave() -> String {
        var addressToDisplay = ""
        if let address = self.attributes?["Address"] as? String, !address.isEmpty {
            addressToDisplay = "\(address), \(self.attributes?["City"] ?? "")"
        } else {
            addressToDisplay = self.attributes?["Match_addr"] as? String ?? ""
        }
        
        return addressToDisplay
    }
}
