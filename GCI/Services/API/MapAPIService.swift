//
//  MapAPIService.swift
//  GCI
//
//  Created by Anthony Chollet on 07/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol MapAPIService {
    
    func getAddress(fromX x: Double, andY y: Double, completionHandler: @escaping RequestJSONCallback)
}
