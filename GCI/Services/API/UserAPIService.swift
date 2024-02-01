//
//  UserAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol UserAPIService {
    
    func user(completionHandler: @escaping RequestJSONCallback)
    
}
