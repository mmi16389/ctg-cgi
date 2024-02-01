//
//  ConfigurationAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ConfigurationAPIService {
    
    func configuration(_ completionHandler: @escaping RequestJSONCallback)
    
    func mapConfiguration(_ completionHandler: @escaping RequestJSONCallback)
}
