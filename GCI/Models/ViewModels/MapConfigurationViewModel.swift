//
//  MapConfigurationViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 3/12/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

class MapConfigurationViewModel {
    
    let exportTileUser: String
    let exportTilePassword: String
    let licenseKey: String
    
    private init(exportTileUser: String, exportTilePassword: String, licenseKey: String) {
        self.exportTileUser = exportTileUser
        self.exportTilePassword = exportTilePassword
        self.licenseKey = licenseKey
    }
    
}

extension MapConfigurationViewModel {
    
    static func from(json: JSON) -> MapConfigurationViewModel? {
        guard let exportTileUser = json["exportTileUser"].string,
            let exportTilePassword = json["exportTilePassword"].string,
            let licenseKey = json["licenseKey"].string else {
                return nil
        }
        
        return MapConfigurationViewModel(
            exportTileUser: exportTileUser,
            exportTilePassword: exportTilePassword,
            licenseKey: licenseKey
        )
    }
}
