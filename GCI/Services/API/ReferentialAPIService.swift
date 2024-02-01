//
//  ReferentialAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ReferentialAPIService {
    
    func referention(withAlreadyKnowMaps idsMap: [Int], andwithAlreadyKnowZones idsZone: [Int], completion: @escaping RequestJSONCallback)
}
