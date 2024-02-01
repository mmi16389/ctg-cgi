//
//  MapDataService.swift
//  GCI
//
//  Created by Anthony Chollet on 07/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

protocol MapDataService {
    typealias Callback = (_ result: ViewModelResult<AGSAddressViewModel?>) -> Void
    
    func getAddressFromPoint(withAGSPoint agsPoint: AGSPoint, completion: @escaping Callback)
    
}
